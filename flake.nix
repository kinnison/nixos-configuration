{
  description = ''
    # NixOS configurations, modules, home-manager modules, packages, et al.

    This flake contains host configurations, nixos modules, home-manager modules,
    various packages, and other content, all by Daniel Silverstone.
  '';

  inputs = {
    # While we don't use flake-utils, various of our sub-flakes do
    flake-utils.url = "github:numtide/flake-utils";
    # Ditto for flake-compat
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # Core nix stuff
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOs/nixos-hardware";
    # Home Manager for home directories
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Styling
    stylix = {
      # Swap back to release-24.11 when the branch is made
      url = "github:danth/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };
    catppuccin.url = "github:catppuccin/nix";
    # Disk setup
    disko = {
      url = "github:nix-community/disko/v1.8.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        # Note, we do not need pre-commit-hooks-nix and its dependencies for building
        # but this introduces a loop in the flakes ("" is self) hence the toplevelMarker
        # below.
        pre-commit-hooks-nix.follows = "";
      };
    };
    # Impermanence support
    impermanence.url = "github:nix-community/impermanence";

    # Backdrops
    cats = {
      url = "github:kinnison/cats-backgrounds";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    # My personal prompter
    prompter = {
      url = "github:kinnison/prompter";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, flake-utils, flake-compat, nixpkgs, nixos-hardware
    , home-manager, catppuccin, stylix, disko, cats, prompter, lanzaboote
    , impermanence }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      overlays = [
        (final: prev:
          let
            cats = inputs.cats.packages.${prev.system}.cats;
            prompter = inputs.prompter.packages.${prev.system}.prompter;
          in {
            kinnison = (import ./packages { pkgs = final; }) // {
              inherit cats;
              prompter = prompter;
            };
          })
      ];
      defaultSystemModules = [
        catppuccin.nixosModules.catppuccin
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        self.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
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
      systemPair = name: body:
        let
          installerBody = body // {
            modules = body.modules ++ [{ kinnison.installer-image = true; }];
          };
        in {
          "${name}" = nixpkgs.lib.nixosSystem body;
          "${name}-installable" = nixpkgs.lib.nixosSystem installerBody;
        };
    in {
      # We use this to detect if we recurse back into ourselves during flake traversal
      toplevelMarker = "kinnison";
      # Normal flake outputs
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in (import ./packages) { inherit pkgs; });
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in with pkgs; { default = mkShell { buildInputs = [ gnumake ]; }; });
      nixosModules.default = import ./nixos-modules;
      nixosConfigurations =
        # The test system is used by `make runvm` et al.
        (systemPair "test" {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules
            ++ [ ./systems/test/configuration.nix ];
        }) //
        # Daniel's personal laptop
        (systemPair "catalepsy" {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules ++ [
            nixos-hardware.nixosModules.lenovo-thinkpad-t480
            ./systems/catalepsy/configuration.nix
          ];
        }) // {
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
