# Wayland based configuration
{ osConfig, lib, ... }:
let
  inherit (lib) mkIf;
  guicfg = osConfig.kinnison.gui;
in {
  config = mkIf guicfg.wayland.enable {
    programs.swaylock = {
      enable = true;
      catppuccin.enable = true;
    };
    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      systemd.enable = true;
      config.bars = [ ];
      config.input."type:keyboard" = {
        xkb_layout = "gb";
        #xkb_options = "";
      };
    };

    programs.foot = {
      enable = true;
      catppuccin.enable = true;
    };

    programs.waybar = {
      enable = true;
      catppuccin.enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };
  };
}
