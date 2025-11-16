# The various Radicle related things
{ osConfig, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.radicle;
  guicfg = osConfig.kinnison.gui;
in {
  options.kinnison.radicle = { enable = mkEnableOption "Radicle support"; };

  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [{
        assertion = config.kinnison.git.enable;
        message = "Radicle makes no sense without git";
      }];
      home.packages = with pkgs; [ radicle-node ];
    })
    (mkIf (cfg.enable && guicfg.enable) {
      home.packages = with pkgs; [ radicle-desktop ];
    })
  ];
}
