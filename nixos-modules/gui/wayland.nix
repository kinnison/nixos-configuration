# Wayland GUI setup
{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.kinnison.gui.wayland;
  enable = config.kinnison.gui.enable && cfg.enable;
in {
  options.kinnison.gui.wayland = { enable = mkEnableOption "Wayland GUI"; };

  config = mkIf enable {
    programs.sway = {
      enable = true;
      xwayland.enable = true;
      extraPackages = [ ];
    };

    xdg.portal = {
      enable = true;
      # Enable wlroots portal (swayish)
      wlr.enable = true;
      # Enable GTK portal for GTK apps
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = { common = { default = "wlr"; }; };
    };

    boot.plymouth = {
      enable = true;
      catppuccin.enable = true;
    };
    stylix.targets.plymouth.enable = false;

    boot.initrd.systemd.enable = true;
    boot.kernelParams = [ "quiet" "splash" ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      catppuccin.enable = true;
      catppuccin.fontSize = "20";
      package = pkgs.kdePackages.sddm;
    };

    fonts.packages = with pkgs; [
      noto-fonts
      fira-code
      fira-code-symbols
      inconsolata
      font-awesome
      (nerdfonts.override {
        fonts = [ "FiraCode" "DroidSansMono" "Inconsolata" ];
      })
    ];

    #environment.systemPackages = with pkgs; [
    #];

    hardware.opengl.enable = true;

    kinnison.user.groups = [ "input" ];
  };
}
