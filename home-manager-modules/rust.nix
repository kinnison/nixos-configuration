# Rust configuration for home directory
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.rust;
  dataHome = config.xdg.dataHome;
in {
  options.kinnison.rust = {
    enable = mkEnableOption "Rust (via rustup)";
    package = mkOption {
      description = "Package for rustup";
      type = types.package;
      default = pkgs.rustup;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.sessionVariables = {
      RUSTUP_HOME = "${dataHome}/rustup";
      CARGO_HOME = "${dataHome}/cargo";
    };
    home.sessionPath = [ "${dataHome}/cargo/bin" ];
  };
}
