# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, overlays, inputs }:

name:
{
  biometricSupport,
  darwin ? false,
  displaySize,
  osVersion,
  system,
  user,
  wsl ? false,
  year
}:

let
  # True if this is a WSL system.
  isWSL = wsl;

  currentSystemUser = user;

  # The config files for this system.
  # Take the substring "macbook-pro" from e.g. "macbook-pro-intel"
  machineConfig = ../machines/${if darwin then builtins.substring 0 11 name else name}.nix;
  userOSConfig = ../users/template/${if darwin then "darwin.nix" else "nixos.nix" };
  userHMConfig = ../users/template/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in systemFunc rec {
  inherit system;

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.backupFileExtension = "home-manager-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${currentSystemUser} = import userHMConfig {
        inherit isWSL inputs currentSystemUser;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inherit isWSL inputs currentSystemUser;
        currentSystem = system;
        currentSystemName = name;
        currentSystemOSVersion = if darwin then (if osVersion != "" then osVersion else "15") else "";
        currentSystemHasBiometricSupport = biometricSupport;
        currentSystemDisplaySize = displaySize;
        currentSystemProductionYear = year;
      };
    }
  ];
}
