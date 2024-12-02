# Gaming stuff (eg steam)
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.gaming;
in {
  options.kinnison.gaming = { steam = mkEnableOption "Enable Steam"; };

  config = mkIf cfg.steam {
    assertions = [{
      assertion = config.kinnison.gui.enable;
      message = "The steam client needs a gui to make sense";
    }];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    kinnison.unfree.pkgs =
      [ "steamcmd" "steam-run" "steam-original" "steam" "steam-unwrapped" ];
    environment.systemPackages = with pkgs; [ protontricks steamcmd ];
  };
}
