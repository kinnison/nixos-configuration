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
        #pointerCursor.enable = true;
      };
      # https://github.com/catppuccin/gtk/issues/262
      # Essentially don't bother - GTK is impossible to theme properly
      # unless you're GNOME
      #gtk.catppuccin = {
      #  enable = true;
      #  icon.enable = true;
      #};
      gtk.enable = true;
      qt = {
        enable = true;
        style.name = "kvantum";
        platformTheme.name = "kvantum";
        style.catppuccin.enable = true;
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
