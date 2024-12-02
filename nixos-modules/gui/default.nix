{ lib, config, pkgs, ... }:
let
  cfg = config.kinnison.gui;
  mkUpper = str:
    (lib.toUpper (builtins.substring 0 1 str))
    + (builtins.substring 1 (builtins.stringLength str) str);
  cursor-name = "${cfg.theme}${mkUpper cfg.accent}";
in {
  imports = [ ./wayland.nix ];
  options.kinnison.gui = {
    enable = lib.mkEnableOption "gui";
    theme = lib.mkOption {
      default = "mocha";
      description = "Which Catppuccin theme to use";
    };

    upperTheme = lib.mkOption {
      description = "The 'theme' with the first letter capitalised";
      readOnly = true;
    };

    accent = lib.mkOption {
      default = "mauve";
      description = "Which Catppuccin accent colour to use";
    };

    upperAccent = lib.mkOption {
      description = "The 'accent' with the first letter capitalised";
      readOnly = true;
    };
  };
  config = lib.mkIf cfg.enable {
    kinnison.gui.upperTheme = mkUpper cfg.theme;
    kinnison.gui.upperAccent = mkUpper cfg.accent;
    catppuccin.enable = true;
    catppuccin.flavor = lib.mkDefault cfg.theme;
    catppuccin.accent = lib.mkDefault cfg.accent;
    console.catppuccin.enable = false;
    environment.systemPackages = lib.mkMerge [
      (lib.mkIf config.kinnison.network-manager.enable
        [ pkgs.networkmanagerapplet ])
      [ config.stylix.cursor.package ]
    ];
    stylix = {
      enable = true;
      image = config.lib.stylix.pixel "base01";
      base16Scheme = ./themes/catppuccin-${cfg.theme}.yaml;
      polarity = "dark";
      cursor = {
        name = "catppuccin-${cfg.theme}-${cfg.accent}-cursors";
        package = pkgs.catppuccin-cursors.${cursor-name};
        size = 16;
      };
    };
    services.displayManager.sddm.settings.Theme = {
      cursorTheme = config.stylix.cursor.name;
      cursorSize = config.stylix.cursor.size;
    };
    services.udisks2.enable = true;
  };
}
