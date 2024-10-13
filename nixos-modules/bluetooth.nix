{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkDefault;
  cfg = config.kinnison.bluetooth;
in {
  options.kinnison.bluetooth = { enable = mkEnableOption "Bluetooth"; };

  config = mkMerge [
    { kinnison.bluetooth = { enable = mkDefault true; }; }
    (mkIf cfg.enable { services.blueman.enable = true; })
  ];
}
