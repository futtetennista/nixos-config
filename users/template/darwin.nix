{ currentSystemUser, currentSystemHasBiometricSupport, inputs, lib, pkgs, ... }:

{
  launchd = {
    agents = {
      docker-system-prune = {
        serviceConfig = {
          ProgramArguments = ["/run/current-system/sw/bin/docker" "system" "prune" "--force" "--volumes"] ;
          RunAtLoad = true;
          StandardErrorPath = "/var/log/launch_agent-docker-system-prune.std-err";
          StandardOutPath = "/var/log/launch_agent-docker-system-prune.out-err";
          StartInterval = 86400;
        };
      };
      nix-collect-garbage = {
        serviceConfig = {
          ProgramArguments = ["/run/current-system/sw/bin/nix-collect-garbage" "-d"] ;
          RunAtLoad = true;
          StandardErrorPath = "/var/log/launch_agent-nix-collect-garbage.std-err";
          StandardOutPath = "/var/log/launch_agent-nix-collect-garbage.std-out";
          StartInterval = 604800;
        };
      };
    };
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix { inherit inputs; })
  ];

  homebrew = {
    enable = true;
    casks  = [
      {
        name = "1password";
        args = { require_sha = true; };
      }
      {
        name = "appcleaner";
        args = { require_sha = true; };
      }
      # "alfred"
      "anki"
      # "cleanshot"
      "calibre"
      "discord"
      {
        name = "firefox";
        args = { require_sha = true; };
      }
      {
        name = "flux";
        args = { require_sha = true; };
      }
      "google-chrome"
      "gpg-suite"
      {
        name = "openoffice";
        args = { require_sha = true; };
      }
      {
        name = "proton-drive";
        args = { require_sha = true; };
      }
      {
        name = "raycast";
        args = { require_sha = true; };
      }
      {
        name = "rectangle";
        args = { require_sha = true; };
      }
      {
        name = "slack";
        args = { require_sha = true; };
      }
      "spotify"
      {
        name = "visual-studio-code";
        args = { require_sha = true; };
      }
      "zoom"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      Bear = 1091189122;
      Kindle = 302584613;
      # Install it through the Mac App Store because the Homebrew version wasn't working correctly.
      NordVPN = 905953485;
      XCode = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      extraFlags = [
        "--verbose"
      ];
      upgrade = false;
    };
  };

  security.pam.enableSudoTouchIdAuth = currentSystemHasBiometricSupport;

  # nix-darwin doesn't expose any API for this, so we have to do it manually.
  system.activationScripts.postActivation.text = builtins.readFile ./add_login_items.sh;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    screencapture.location = "/Users/${currentSystemUser}/screenshots";
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    # To get these values I run:
    # $ defaults read
    # on a machine that was already set up
    # and then I manually "nix-ified" the values.
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
      # NOTE: you need to logout or restart your computer for these changes to take effect.
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "10" = {
            enabled = false;
            value = { parameters = [65535 96 8650752]; type = "standard"; };
          };
          "11" = {
            enabled = false;
            value = { parameters = [65535 97 8650752]; type = "standard"; };
          };
          "118" = {
            enabled = false;
            value = { parameters = [65535 18 262144]; type = "standard"; };
          };
          "12" = {
            enabled = false;
            value = { parameters = [65535 122 8650752]; type = "standard"; };
          };
          "13" = {
            enabled = false;
            value = { parameters = [65535 98 8650752]; type = "standard"; };
          };
          "15" = {
            enabled = false;
            value = { parameters = [56 28 1572864]; type = "standard"; };
          };
          "16" = {
            enabled = false;
          };
          "160" = {
            enabled = false;
            value = { parameters = [65535 65535 0]; type = "standard"; };
          };
          "162" = {
            enabled = true;
            value = { parameters = [65535 96 9961472]; type = "standard"; };
          };
          "163" = {
            enabled = false;
            value = { parameters = [65535 65535 0]; type = "standard"; };
          };
          "164" = {
            enabled = true;
            value = { parameters = [262144 4294705151]; type = "modifier"; };
          };
          "17" = {
            enabled = false;
            value = { parameters = [43 24 1572864]; type = "standard"; };
          };
          "175" = {
            enabled = true;
            value = { parameters = [65535 65535 0]; type = "standard"; };
          };
          "179" = {
            enabled = false;
            value = { parameters = [65535 65535 0]; type = "standard"; };
          };
          "18" = {
            enabled = false;
          };
          "19" = {
            enabled = false;
            value = { parameters = [45 27 1572864]; type = "standard"; };
          };
          "20" = {
            enabled = false;
          };
          "21" = {
            enabled = false;
            value = { parameters = [56 28 1835008]; type = "standard"; };
          };
          "22" = {
           enabled = false;
          };
          "23" = {
           enabled = false;
           value = { parameters = [35 0 1572864]; type = "standard"; };
          };
          "24" = {
            enabled = false;
          };
          "25" = {
            enabled = false;
            value = { parameters = [46 47 1835008]; type = "standard"; };
          };
          "26" = {
            enabled = false;
            value = { parameters = [44 43 1835008]; type = "standard"; };
          };
          "27" = {
            enabled = true;
            value = { parameters = [65535 48 524288]; type = "standard"; };
          };
          "28" = {
            enabled = true;
            value = { parameters = [51 20 1179648]; type = "standard"; };
          };
          "29" = {
            enabled = true;
            value = { parameters = [51 20 1441792]; type = "standard"; };
          };
          "30" = {
            enabled = true;
            value = { parameters = [52 21 1179648]; type = "standard"; };
          };
          "31" = {
            enabled = true;
            value = { parameters = [52 21 1441792]; type = "standard"; };
          };
          "32" = {
            enabled = true;
            value = { parameters = [65535 126 8650752]; type = "standard"; };
          };
          "33" = {
            enabled = true;
            value = { parameters = [65535 125 8650752]; type = "standard"; };
          };
          "34" = {
            enabled = true;
            value = { parameters = [65535 126 8781824]; type = "standard"; };
          };
          "35" = {
            enabled = true;
            value = { parameters = [65535 125 8781824]; type = "standard"; };
          };
          "36" = {
            enabled = true;
            value = { parameters = [65535 103 8388608]; type = "standard"; };
          };
          "37" = {
            enabled = true;
            value = { parameters = [65535 103 8519680]; type = "standard"; };
          };
          "51" = {
            enabled = true;
            value = { parameters = [96 50 1572864]; type = "standard"; };
          };
          "52" = {
            enabled = true;
            value = { parameters = [100 2 1572864]; type = "standard"; };
          };
          "53" = {
            enabled = true;
            value = { parameters = [65535 107 0]; type = "standard"; };
          };
          "54" = {
            enabled = true;
            value = { parameters = [65535 113 0]; type = "standard"; };
          };
          "55" = {
            enabled = true;
            value = { parameters = [65535 107 524288]; type = "standard"; };
          };
          "56" = {
            enabled = true;
            value = { parameters = [65535 113 524288]; type = "standard"; };
          };
          "57" = {
            enabled = false;
            value = { parameters = [65535 100 8650752]; type = "standard"; };
          };
          "59" = {
            enabled = true;
            value = { parameters = [65535 96 9437184]; type = "standard"; };
          };
          "60" = {
            enabled = false;
            value = { parameters = [32 49 262144]; type = "standard"; };
          };
          "61" = {
            enabled = false;
            value = { parameters = [32 49 786432]; type = "standard"; };
          };
          "62" = {
            enabled = true;
            value = { parameters = [65535 111 8388608]; type = "standard"; };
          };
          "63" = {
            enabled = true;
            value = { parameters = [65535 111 8519680]; type = "standard"; };
          };
          # Disable CMD+SPACE for Spotlight
          "64" = {
            enabled = false;
            value = { parameters = [65535 49 1048576]; type = "standard"; };
          };
          # Disable CMD+Option+SPACE for Spotlight window
          "65" = {
            enabled = false;
            value = { parameters = [65535 49 1572864]; type = "standard"; };
          };
          "7" = {
            enabled = false;
            value = { parameters = [65535 120 8650752]; type = "standard"; };
          };
          "79" = {
            enabled = true;
            value = { parameters = [65535 123 8650752]; type = "standard"; };
          };
          "8" = {
            enabled = false;
            value = { parameters = [65535 99 8650752]; type = "standard"; };
          };
          "80" = {
            enabled = true;
            value = { parameters = [65535 123 8781824]; type = "standard"; };
          };
          "81" = {
            enabled = true;
            value = { parameters = [65535 124 8650752]; type = "standard"; };
          };
          "82" = {
            enabled = true;
            value = { parameters = [65535 124 8781824]; type = "standard"; };
          };
          "9" = {
            enabled = false;
            value = { parameters = [65535 118 8650752]; type = "standard"; };
          };
          "98" = {
            enabled = false;
            value = { parameters = [47 44 1179648]; type = "standard"; };
          };
        };
      };
    };
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.${currentSystemUser} = {
    home = /Users/${currentSystemUser};
    shell = pkgs.zsh;
  };
}
