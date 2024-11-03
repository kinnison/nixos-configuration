{
  description = ''
    # NixOS configurations, modules, home-manager modules, packages, et al.

    This flake contains host configurations, nixos modules, home-manager modules,
    various packages, and other content, all by Daniel Silverstone.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOs/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix/release-24.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";
    catppuccin.url = "github:catppuccin/nix";
    disko.url = "github:nix-community/disko/v1.8.2";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    cats.url = "github:kinnison/cats-backgrounds";
    cats.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager
    , catppuccin, stylix, disko, cats }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable { system = prev.system; };
        })
        (final: prev:
          let cats = inputs.cats.packages.${prev.system}.cats;
          in {
            kinnison = (import ./packages { pkgs = final; }) // {
              inherit cats;
            };
          })
      ];
      defaultSystemModules = [
        catppuccin.nixosModules.catppuccin
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        self.nixosModules.default
        {
          _module.args = {
            homes = self.homes;
            hm-modules = [
              catppuccin.homeManagerModules.catppuccin
              (import ./home-manager-modules)
            ];
          };
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
      nixosConfigurations = {
        # The test system is used by `make runvm` et al.
        test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules
            ++ [ ./systems/test/configuration.nix ];
        };
        # Daniel's personal laptop
        catalepsy = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules ++ [
            nixos-hardware.nixosModules.lenovo-thinkpad-t480
            ./systems/catalepsy/configuration.nix
          ];
        };
        # The installer contains all of the above systems, including disko support
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules ++ [
            {
              _module.args = {
                systems = self.nixosConfigurations;
                flakeInputs = inputs;
              };
            }
            ./systems/installer/configuration.nix
            {
              environment.systemPackages = [
                disko.packages.x86_64-linux.disko-install
                disko.packages.x86_64-linux.disko
              ];
            }
          ];
        };
      };

      lib = { inherit defaultSystemModules; };

      homes = {
        dsilvers = ./homes/dsilvers;
        installer = ./homes/installer;
      };
    };
}
