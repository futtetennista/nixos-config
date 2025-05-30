{ config, lib, pkgs, currentSystemOSVersion, currentSystemUser, ... }:

{
  # Set in Sept 2024 as part of the macOS Sequoia release.
  system.stateVersion = 5;

  # Fix to the following error on Intel Macs:
  # > The default Nix build user ID range has been adjusted for
  # > compatibility with macOS Sequoia 15. Your _nixbld1 user currently has
  # > UID 301 rather than the new default of 351.
  # > If you have no intention of upgrading to macOS Sequoia 15, or already
  # > have a custom UID range that you know is compatible with Sequoia, you
  # > can disable this check by setting:
  ids.uids.nixbld = lib.mkIf (currentSystemOSVersion != "15") 300;

  # Keep in async with vm-shared.nix. (todo: pull this out into a file)
  nix = {
    # Determinate uses its own daemon to manage the Nix installation that
    # conflicts with nix-darwin’s native Nix management.
    # To turn off nix-darwin’s management of the Nix installation.
    # This will allow you to use nix-darwin with Determinate. Some nix-darwin
    # functionality that relies on managing the Nix installation, like the
    # `nix.*` options to adjust Nix settings or configure a Linux builder,
    # will be unavailable.
    enable = false;

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
      extra-substituters = [];
      extra-trusted-public-keys = [];
    };
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh = {
    enable = true;
    shellInit = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix

      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
      # End Homebrew
    '';
  };

  environment.shells = with pkgs; [ bashInteractive zsh ];
}
