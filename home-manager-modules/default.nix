# The various packages provided directly by my system and home configs
{ lib, osConfig, ... }:
let
  inherit (lib) mkMerge mkIf;
  guicfg = osConfig.kinnison.gui;
  nmcfg = osConfig.kinnison.network-manager;
in {
  imports = [ ./wayland.nix ];
  config = mkMerge [
    (mkIf guicfg.enable {
      catppuccin = {
        enable = true;
        flavor = guicfg.theme;
        accent = guicfg.accent;
        pointerCursor.enable = true;
      };
      gtk.catppuccin = {
        enable = true;
        icon.enable = true;
      };
    })
    (mkIf nmcfg.enable { services.network-manager-applet.enable = true; })
  ];
}
