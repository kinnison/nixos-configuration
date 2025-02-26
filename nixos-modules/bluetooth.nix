{ config, lib, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkDefault;
  cfg = config.kinnison.bluetooth;
  imperm = config.kinnison.impermanence.enable;
in {
  options.kinnison.bluetooth = { enable = mkEnableOption "Bluetooth"; };

  config = mkMerge [
    { kinnison.bluetooth = { enable = mkDefault true; }; }
    (mkIf cfg.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      kinnison.impermanence.directories = mkIf imperm [ "/var/lib/bluetooth" ];
    })
  ];
}
