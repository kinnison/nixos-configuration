{ lib, config, pkgs, ... }:
let cfg = config.kinnison.gui;
in {
  imports = [ ./wayland.nix ];
  options.kinnison.gui = {
    enable = lib.mkEnableOption "gui";
    theme = lib.mkOption {
      default = "mocha";
      description = "Which Catppuccin theme to use";
    };
    accent = lib.mkOption {
      default = "mauve";
      description = "Which Catppuccin accent colour to use";
    };
  };
  config = lib.mkIf cfg.enable {
    catppuccin.enable = true;
    catppuccin.flavor = lib.mkDefault cfg.theme;
    catppuccin.accent = lib.mkDefault cfg.accent;
    console.catppuccin.enable = false;
    environment.systemPackages = lib.mkIf config.kinnison.network-manager.enable
      [ pkgs.networkmanagerapplet ];
    stylix = {
      enable = true;
      image = config.lib.stylix.pixel "base01";
      base16Scheme =
        "${pkgs.base16-schemes}/share/themes/catppuccin-${cfg.theme}.yaml";
      polarity = "dark";
    };
  };
}
