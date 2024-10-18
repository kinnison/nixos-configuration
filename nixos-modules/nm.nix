{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.kinnison.network-manager;
in {
  options.kinnison.network-manager = {
    enable = mkEnableOption "Network Manager based networking";
  };
  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
    kinnison.user.groups = [ "networkmanager" ];
    networking.wireless.enable = mkForce false;
  };
}
