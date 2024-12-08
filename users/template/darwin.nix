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
    enable = true;
    casks  = [
      "1password"
      "alfred"
      "anki"
      # "cleanshot"
      "discord"
      "firefox"
      "google-chrome"
      # "nordvpn"
      "openoffice"
      "raycast"
      "rectangle"
      "slack"
      "spotify"
      "visual-studio-code"
    ];
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.${currentSystemUser} = {
    home = /Users/${currentSystemUser};
    shell = pkgs.zsh;
  };
}
