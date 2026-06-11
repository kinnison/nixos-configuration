{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkForce
    mkMerge
    mkDefault
    ;
  cfg = config.kinnison.network-manager;
  imperm = config.kinnison.impermanence.enable;
in
{
  options.kinnison.network-manager = {
    enable = mkEnableOption "Network Manager based networking";
    wireless = mkEnableOption "Network Manager based wireless support";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      networking.networkmanager.enable = true;
      kinnison.user.groups = [ "networkmanager" ];
      # This is now needed for Network Manager
      networking.wireless.enable = mkForce cfg.wireless;
      kinnison.impermanence.directories = mkIf imperm [
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
      ];
    })
    { kinnison.network-manager.wireless = mkDefault true; }
  ];
}
