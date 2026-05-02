# The various Radicle related things
{ osConfig, config, lib, pkgs, writeShellApplication, ... }:
with lib;
let
  cfg = config.kinnison.radicle;
  guicfg = osConfig.kinnison.gui;
  radicle-desktop = pkgs.writeShellApplication {
    name = "radicle-desktop";
    runtimeInputs = [ pkgs.radicle-desktop ];
    text = ''
      env __NV_DISABLE_EXPLICIT_SYNC=1 ${pkgs.radicle-desktop}/bin/radicle-desktop "$@"
    '';
  };
in {
  options.kinnison.radicle = {
    enable = mkEnableOption "Radicle support";
    allowListen = mkEnableOption "Open TCP for listening";
  };

  config = mkMerge [
    { kinnison.radicle.allowListen = mkDefault true; }
    (mkIf cfg.enable {
      assertions = [{
        assertion = config.kinnison.git.enable;
        message = "Radicle makes no sense without git";
      }];
      home.packages = with pkgs; [ radicle-node ];
    })
    (mkIf (cfg.enable && guicfg.enable) {
      home.packages = [ radicle-desktop ];

      kinnison.allowedTCPPorts = mkIf cfg.allowListen [ 8776 ];
    })
  ];
}
