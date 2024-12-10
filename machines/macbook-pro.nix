{ config, lib, pkgs, currentSystemVersion, currentSystemUser, ... }:

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
  ids.uids.nixbld = lib.mkIf (currentSystemVersion != "Sequoia15") 300;

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
      extra-substituters = ["@@nixCache.url@@"];
      extra-trusted-public-keys = ["@@nixCache.publicKey@@"];
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
    '';
  };

  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.systemPackages = with pkgs; [
    cachix
    curl
    docker
    gh
    git
    git-crypt
    jq
    npins
    pre-commit
    shellcheck
  ];

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    screencapture.location = "~/Desktop/screenshots";
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        # Enable standard function keys (F1, F2, etc.)
        "com.apple.keyboard.fnState" = true;
        # Enable full keyboard access
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        # Set initial key repeat delay (lower = shorter delay until repeat)
        InitialKeyRepeat = 15;
        # Set key repeat rate (lower = faster)
        KeyRepeat = 2;
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "10" = {
              enabled = false;
              value = "{ parameters = ( 65535, 96, 8650752); type = standard; }";
          };
          "11" = {
              enabled = false;
              value = "{ parameters = ( 65535, 97, 8650752); type = standard; }";
          };
          "118" = {
              enabled = false;
              value = "{ parameters = ( 65535, 18, 262144); type = standard; }";
          };
          "12" = {
              enabled = false;
              value = "{ parameters = ( 65535, 122, 8650752); type = standard; }";
          };
          "13" = {
              enabled = false;
              value = "{ parameters = ( 65535, 98, 8650752); type = standard; }";
          };
          "15" = {
              enabled = false;
              value = "{ parameters = ( 56, 28, 1572864); type = standard; }";
          };
          "16" = {
              enabled = false;
          };
          "160" = {
            enabled = false;
            value = "{ parameters = ( 65535, 65535, 0); type = standard; }";
          };
          "162" = {
            enabled = true;
            value = "{ parameters = ( 65535, 96, 9961472); type = standard; }";
          };
          "163" = {
            enabled = false;
            value = "{ parameters = ( 65535, 65535, 0); type = standard; }";
          };
          "164" = {
            enabled = true;
            value = "{ parameters = ( 262144, 4294705151); type = modifier; }";
          };
          "17" = {
            enabled = false;
            value = "{ parameters = ( 43, 24, 1572864); type = standard; }";
          };
          "175" = {
              enabled = true;
              value = "{ parameters = ( 65535, 65535, 0); type = standard; }";
          };
          "179" = {
            enabled = false;
            value = "{ parameters = ( 65535, 65535, 0); type = standard; }";
          };
          "18" = {
            enabled = false;
          };
          "19" = {
            enabled = false;
            value = "{ parameters = ( 45, 27, 1572864 ); type = standard; }";
          };
          "20" = {
            enabled = false;
          };
          "21" = {
            enabled = false;
            value = "{ parameters = ( 56, 28, 1835008); type = standard; }";
          };
          "22" = {
             enabled = false;
           };
          "23" = {
             enabled = false;
             value = "{ parameters = ( 35, 0, 1572864); type = standard; }";
           };
          "24" = {
            enabled = false;
          };
          "25" = {
            enabled = false;
            value = "{ parameters = ( 46, 47, 1835008); type = standard; }";
          };
          "26" = {
            enabled = false;
            value = "{ parameters = ( 44, 43, 1835008); type = standard; }";
          };
          "27" = {
            enabled = true;
            value = "{ parameters = ( 65535, 48, 524288); type = standard; }";
          };
          "28" = {
            enabled = true;
            value = "{ parameters = ( 51, 20, 1179648); type = standard; }";
          };
          "29" = {
            enabled = true;
            value = "{ parameters = ( 51, 20, 1441792); type = standard; }";
          };
          "30" = {
              enabled = true;
              value = "{ parameters = ( 52, 21, 1179648); type = standard; }";
          };
          "31" = {
              enabled = true;
              value = "{ parameters = ( 52, 21, 1441792); type = standard; }";
          };
          "32" = {
              enabled = true;
              value = "{ parameters = ( 65535, 126, 8650752); type = standard; }";
          };
          "33" = {
              enabled = true;
              value = "{ parameters = ( 65535, 125, 8650752); type = standard; }";
          };
          "34" = {
              enabled = true;
              value = "{ parameters = ( 65535, 126, 8781824); type = standard; }";
          };
          "35" = {
              enabled = true;
              value = "{ parameters = ( 65535, 125, 8781824); type = standard; }";
          };
          "36" = {
              enabled = true;
              value = "{ parameters = ( 65535, 103, 8388608); type = standard; }";
          };
          "37" = {
              enabled = true;
              value = "{ parameters = ( 65535, 103, 8519680); type = standard; }";
          };
          "51" = {
              enabled = true;
              value = "{ parameters = ( 96, 50, 1572864); type = standard; }";
          };
          "52" = {
              enabled = true;
              value = "{ parameters = ( 100, 2, 1572864); type = standard; }";
          };
          "53" = {
              enabled = true;
              value = "{ parameters = ( 65535, 107, 0); type = standard; }";
          };
          "54" = {
              enabled = true;
              value = "{ parameters = ( 65535, 113, 0); type = standard; }";
          };
          "55" = {
              enabled = true;
              value = "{ parameters = ( 65535, 107, 524288); type = standard; }";
          };
          "56" = {
              enabled = true;
              value = "{ parameters = ( 65535, 113, 524288); type = standard; }";
          };
          "57" = {
              enabled = false;
              value = "{ parameters = ( 65535, 100, 8650752); type = standard; }";
          };
          "59" = {
              enabled = true;
              value = "{ parameters = ( 65535, 96, 9437184); type = standard; }";
          };
          "60" = {
              enabled = false;
              value = "{ parameters = ( 32, 49, 262144); type = standard; }";
          };
          "61" = {
              enabled = false;
              value = "{ parameters = ( 32, 49, 786432); type = standard; }";
          };
          "62" = {
              enabled = true;
              value = "{ parameters = ( 65535, 111, 8388608); type = standard; }";
          };
          "63" = {
              enabled = true;
              value = "{ parameters = ( 65535, 111, 8519680); type = standard; }";
          };
          # Disable CMD+SPACE for Spotlight
          "64" = {
              enabled = false;
              value = "{ parameters = ( 65535, 49, 1048576); type = standard; }";
          };
          # Disable CMD+Option+SPACE for Spotlight window
          "65" = {
            enabled = false;
            value = "{ parameters = ( 65535, 49, 1572864) type = standard; }";
          };
          "7" = {
            enabled = false;
            value = "{ parameters = ( 65535, 120, 8650752); type = standard; }";
          };
          "79" = {
            enabled = true;
            value = "{ parameters = ( 65535, 123, 8650752); type = standard; }";
          };
          "8" = {
            enabled = false;
            value = "{ parameters = ( 65535, 99, 8650752); type = standard; }";
          };
          "80" = {
            enabled = true;
            value = "{ parameters = ( 65535, 123, 8781824); type = standard; }";
          };
          "81" = {
            enabled = true;
            value = "{ parameters = ( 65535, 124, 8650752); type = standard; }";
          };
          "82" = {
            enabled = true;
            value = "{ parameters = ( 65535, 124, 8781824); type = standard; }";
          };
          "9" = {
            enabled = false;
            value = "{ parameters = ( 65535, 118, 8650752); type = standard; }";
          };
          "98" = {
            enabled = false;
            value = "{ parameters = ( 47, 44, 1179648); type = standard; }";
          };
        };
      };
    };
  };
}
