# The various packages provided directly by my system and home configs
{ lib, pkgs, osConfig, ... }:
let
  inherit (lib) mkMerge mkIf mkForce;
  guicfg = osConfig.kinnison.gui;
  nmcfg = osConfig.kinnison.network-manager;
  bluecfg = osConfig.kinnison.bluetooth;
  mkUpper = str:
    (lib.toUpper (builtins.substring 0 1 str))
    + (builtins.substring 1 (builtins.stringLength str) str);
  cursor-name = "${guicfg.theme}${mkUpper guicfg.accent}";
in {
  imports = [ ./wayland.nix ./gpg.nix ];
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
      home.pointerCursor = {
        name = mkForce "catppuccin-${guicfg.theme}-${guicfg.accent}-cursors";
        package = mkForce pkgs.catppuccin-cursors.${cursor-name};
        size = mkForce 32;
      };
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        settings = {
          device_config = [{
            device_file = "/dev/fd0";
            ignore = true;
          }];
        };
      };
    })
    (mkIf (guicfg.enable && bluecfg.enable) {
      services.blueman-applet.enable = true;
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
        defaultKeymap = "emacs";
      };
      programs.vim = {
        enable = true;
        settings = { background = "dark"; };
        extraConfig = ''
          set mouse=
        '';
        defaultEditor = true;
      };
      xdg = {
        enable = true;
        mimeApps.enable = true;
      };
      home.packages = [ pkgs.at-spi2-atk ];
    }
  ];
}
