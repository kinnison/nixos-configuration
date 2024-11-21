{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.kinnison.network-manager;
  imperm = config.kinnison.impermanence.enable;
in {
  options.kinnison.network-manager = {
    enable = mkEnableOption "Network Manager based networking";
  };
  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
    kinnison.user.groups = [ "networkmanager" ];
    networking.wireless.enable = mkForce false;
    kinnison.impermanence.directories =
      mkIf imperm [ "/etc/NetworkManager/system-connections" ];
    kinnison.impermanence.files = mkIf imperm [
      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"
    ];
  };
}
