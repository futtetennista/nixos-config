{ config, pkgs, ... }:

{ system }:

{
  # Set in Sept 2024 as part of the macOS Sequoia release.
  system.stateVersion = 5;

  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;

  # Fix to the following error on Intel Macs:
  # > The default Nix build user ID range has been adjusted for
  # > compatibility with macOS Sequoia 15. Your _nixbld1 user currently has
  # > UID 301 rather than the new default of 351.
  # > If you have no intention of upgrading to macOS Sequoia 15, or already
  # > have a custom UID range that you know is compatible with Sequoia, you
  # > can disable this check by setting:
  ids.uids.nixbld = lib.mkIf (system == "aarch64-darwin") 300;

  # Keep in async with vm-shared.nix. (todo: pull this out into a file)
  nix = {
    # We need to enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.
    settings = {
      extra-substituters = ["https://futtetennista-nixos-config.cachix.org"];
      extra-trusted-public-keys = ["futtetennista-nixos-config.cachix.org-1:ExARQbiFNQCugALmrVDIgAn/jMbhhEHuZkKXF7W7C1E="];
    };
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    '';

  programs.fish.enable = false;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
    '';

  environment.shells = with pkgs; [ bashInteractive zsh fish ];
  environment.systemPackages = with pkgs; [
    cachix
    docker
  ];

  services.nix-daemon.enable = true;
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    # loginwindow.LoginwindowText = "nixcademy.com";
    screencapture.location = "~/Desktop/screenshots";
    screensaver.askForPasswordDelay = 10;
  };
}
