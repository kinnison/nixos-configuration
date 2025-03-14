{
  description = ''
    # NixOS configurations, modules, home-manager modules, packages, et al.

    This flake contains host configurations, nixos modules, home-manager modules,
    various packages, and other content, all by Daniel Silverstone.
  '';

  inputs = {
    # While we don't use nix-systems, flake-utils, etc. various of our sub-flakes do
    nix-systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "nix-systems";
    flake-compat.url = "github:nix-community/flake-compat";
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
      url = "github:danth/stylix/release-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        systems.follows = "nix-systems";
      };
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
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
    # My personal journalling tool
    juntakami = {
      url = "github:kinnison/juntakami";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

  };

  outputs = { self, nix-systems, flake-utils, flake-compat, nixpkgs
    , nixos-hardware, home-manager, catppuccin, stylix, disko, cats, prompter
    , lanzaboote, impermanence, juntakami, }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      overlays = [
        (final: prev:
          let
            cats = inputs.cats.packages.${prev.system}.cats;
            prompter = inputs.prompter.packages.${prev.system}.prompter;
            juntakami = inputs.juntakami.packages.${prev.system}.juntakami;
          in {
            kinnison = (import ./packages { pkgs = final; }) // {
              inherit cats prompter juntakami;
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
            package = pkgs.nixVersions.stable;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
            settings = { auto-optimise-store = true; };
            channel.enable = false; # We use flakes
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
      makeInstaller = { systems, flakeInputs, baseModules }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = baseModules ++ [
            {
              _module.args = {
                inherit systems;
                inherit flakeInputs;
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
    in {
      # We use this to detect if we recurse back into ourselves during flake traversal
      toplevelMarker = "kinnison";
      # Normal flake outputs
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in (import ./packages) { inherit pkgs; });
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in with pkgs; {
          default = mkShell { buildInputs = [ gnumake nvd ]; };
        });
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
        }) //
        # Daniel's personal desktop
        (systemPair "lassitude" {
          system = "x86_64-linux";
          modules = self.lib.defaultSystemModules ++ [
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            ./systems/lassitude/configuration.nix
          ];
        }) // {
          # The installer contains all of the above systems,
          # adds disko support, and is a GUI installer
          installer = self.lib.makeInstaller {
            baseModules = self.lib.defaultSystemModules;
            flakeInputs = inputs;
            systems = self.nixosConfigurations;
          };
        };

      lib = {
        inherit defaultSystemModules;
        inherit systemPair;
        inherit makeInstaller;
      };

      homes = {
        dsilvers = ./homes/dsilvers;
        installer = ./homes/installer;
      };
    };
}
