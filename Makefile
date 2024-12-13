# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

DIFF_FILE := /tmp/replace_secrets.diff
TEMP_FILES := switch*.sh test*.sh $(DIFF_FILE)

# We need to do some OS switching below.
UNAME := $(shell uname)

ARCH := $(shell arch)

ifeq ($(ARCH), i386)
	NIXNAME ?= macbook-pro-intel
else
	NIXNAME ?= macbook-pro-m1
endif
NIXUSER ?= futtetennista

switch: switch_darwin.sh
ifeq ($(UNAME), Darwin)
	@./switch_darwin.sh && ($(MAKE) cleanup) || (code=$$?; $(MAKE) cleanup; exit $$code)
else
	./replace_secrets.sh$(DIFF_FILE)
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#$(NIXNAME)"
	git apply -R $(DIFF_FILE)
endif

cleanup:
	@echo '[cleanup] Removing temporary files and reverting secrets'
	@git apply -R $(DIFF_FILE)
	@rm -f $(TEMP_FILES)

switch_darwin.sh:
	@echo '#!/usr/bin/env bash' > $@
	@echo 'set -euo pipefail' >> $@
	@echo './replace_secrets.sh $(DIFF_FILE)' >> $@
	@echo 'nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.$(NIXNAME).system"' >> $@
	@echo './result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#$(NIXNAME)"' >> $@
	@chmod +x $@

check:
	$(MAKE) test

test: test_darwin.sh
ifeq ($(UNAME), Darwin)
	@./test_darwin.sh && ($(MAKE) cleanup) || (code=$$?; $(MAKE) cleanup; exit $$code)
else
	./replace_secrets.sh $(DIFF_FILE)
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild check --flake ".#$(NIXNAME)"
	git apply -R $(DIFF_FILE)
endif

test_darwin.sh:
	@echo '#!/usr/bin/env bash' > $@
	@echo 'set -euo pipefail' >> $@
	@echo './replace_secrets.sh $(DIFF_FILE)' >> $@
	@echo 'nix --extra-experimental-features nix-command --extra-experimental-features flakes build ".#darwinConfigurations.$(NIXNAME).system"' >> $@
	@echo './result/sw/bin/darwin-rebuild check --flake "$$(pwd)#$(NIXNAME)"' >> $@
	@chmod +x $@

# This builds the given NixOS configuration and pushes the results to the
# cache. This does not alter the current running system. This requires
# cachix authentication to be configured out of band.
cache:
	./replace_secrets.sh /tmp/replace_secrets.diff
	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json \
		| jq -r '.[].outputs | to_entries[].value' \
		| cachix push ${NIXCACHE}
	git apply -R /tmp/replace_secrets.diff

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# NOTE(mitchellh): I'm sure there is a way to do this and bootstrap all
# in one step but when I tried to merge them I got errors. One day.
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			nix.settings.extra-substituters = [${NIXCACHE_URL}];\n \
			nix.settings.extra-trusted-public-keys = [${NIXCACHE_PUBLIC_KEY}];\n \
  		services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy our secrets into the VM
vm/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#$(NIXNAME)\" \
	"

# Build a WSL installer
.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.installer"
