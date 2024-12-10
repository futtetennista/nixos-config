{ currentSystemUser, inputs, pkgs, ... }:

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
    brews = [
      "gnupg"
    ];
    enable = true;
    casks  = [
      {
        name = "1password";
        args = { require_sha = true; };
      }
      "alfred"
      "anki"
      # "cleanshot"
      # "calibre@6.29"
      "discord"
      {
        name = "firefox";
        args = { require_sha = true; };
      }
      "flux"
      {
        name = "openoffice";
        args = { require_sha = true; };
      }
      "raycast"
      "rectangle"
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
      Bear = 1091189122;
      # Install it through the Mac App Store because the Homebrew version doesn't have a SHA.
      GoogleChrome = 535886823;
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

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.${currentSystemUser} = {
    home = /Users/${currentSystemUser};
    shell = pkgs.zsh;
  };
}
