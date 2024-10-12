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
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        autosuggestion = {
          enable = true;
          # This turns up in newer home-manager?
          # strategy = [ "history" ];
        };
        history = {
          # This turns up in newer home-manager?
          # append = true;
          share = true;
          extended = true;
          ignoreAllDups = true;
          ignoreSpace = true;
        };
        syntaxHighlighting.enable = true;
      };
    }
  ];
}
