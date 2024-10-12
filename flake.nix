{
  description = ''
    # NixOS configurations, modules, home-manager modules, packages, et al.

    This flake contains host configurations, nixos modules, home-manager modules,
    various packages, and other content, all by Daniel Silverstone.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, catppuccin }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable { system = prev.system; };
        })
      ];
      defaultSystemModules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        self.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ({ config, pkgs, ... }: {
          nix = {
            #nixPath = [ "nixpkgs=${nixpkgs}" ];
            #registry.nixpkgs = {
            #  from = {
            #    id = "nixpkgs";
            #    type = "indirect";
            #  };
            #  flake = nixpkgs;
            #};
            package = pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
            settings = { auto-optimise-store = true; };
          };
          nixpkgs.overlays = overlays;
        })
      ];
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in (import ./packages) { inherit pkgs; });
      nixosModules.default = import ./nixos-modules;
      homeManagerModules.default = import ./home-manager-modules;
      nixosConfigurations = {
        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules
            ++ [ ./systems/testvm/configuration.nix ];
        };
      };

      lib = { inherit defaultSystemModules; };
    };
}
