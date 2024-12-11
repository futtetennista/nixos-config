{
  description = "NixOS systems and tools by futtetennista";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Build a custom WSL installer
    # nixos-wsl.url = "github:nix-community/NixOS-WSL";
    # nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # I think technically you're not supposed to override the nixpkgs
    # used by neovim but recently I had failures if I didn't pin to my
    # own. We can always try to remove that anytime.
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

    # Other packages
    # jujutsu.url = "github:martinvonz/jj";
    # zig.url = "github:mitchellh/zig-overlay";
    ormolu.url = "github:tweag/ormolu";

    # Non-flakes
    # name.url = "github:user/repo/ref0";
    # name.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs: let
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      # inputs.jujutsu.overlays.default
      # inputs.zig.overlays.default
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    # nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
    #   system = "aarch64-linux";
    #   user = "futtetennista";
    # };

    # nixosConfigurations.vm-aarch64-prl = mkSystem "vm-aarch64-prl" rec {
    #   system = "aarch64-linux";
    #   user = "futtetennista";
    # };

    # nixosConfigurations.vm-aarch64-utm = mkSystem "vm-aarch64-utm" rec {
    #   system = "aarch64-linux";
    #   user = "futtetennista";
    # };

    # nixosConfigurations.vm-intel = mkSystem "vm-intel" rec {
    #   system = "x86_64-linux";
    #   user = "futtetennista";
    # };

    # nixosConfigurations.wsl = mkSystem "wsl" {
    #   system = "x86_64-linux";
    #   user = "futtetennista";
    #   wsl    = true;
    # };

    darwinConfigurations.macbook-pro-intel = mkSystem "macbook-pro-intel" {
      biometricSupport = false;
      darwin = true;
      system = "x86_64-darwin";
      user = "@@system.user@@";
      version = "Monterey12";
    };

    darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
      biometricSupport = true;
      darwin = true;
      system = "aarch64-darwin";
      user = "@@system.user@@";
    };
  };
}
