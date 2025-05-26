# Rust configuration for home directory
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.rust;
  dataHome = config.xdg.dataHome;
  hasHelix = config.kinnison.helix.enable;
in {
  options.kinnison.rust = {
    enable = mkEnableOption "Rust (via rustup)";
    package = mkOption {
      description = "Package for rustup";
      type = types.package;
      default = pkgs.rustup;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = [ cfg.package ];
      home.sessionVariables = {
        RUSTUP_HOME = "${dataHome}/rustup";
        CARGO_HOME = "${dataHome}/cargo";
      };
      home.sessionPath = [ "${dataHome}/cargo/bin" ];
    })
    (mkIf (cfg.enable && hasHelix) {
      programs.helix.languages = {
        language-server.rust-analyzer.config = {
          assist.emitMustUse = true;
          cargo = {
            buildScripts.enable = true;
            allTargets = true;
          };
          check = {
            allTargets = true;
            command = "clippy";
            workspace = true;
          };
          diagnostics.styleLints.enable = true;
          inlayHints = {
            closureCaptureHints.enable = true;
            closureReturnTypeHints.enable = true;
            implicitDrops.enable = true;
            lifetimeElisionHints.enable = true;
            lifetimeElisionHints.useParameterNames = true;
            maxLength = 40;
          };
          lens = {
            enable = true;
            references = {
              adt.enable = true;
              enumVariant.enable = true;
              trait.enable = true;
              run.enable = false;
            };
          };
          procMacro = {
            enable = true;
            attributes.enable = true;
          };
        };
      };
    })
  ];
}
