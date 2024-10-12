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
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    boot.plymouth = {
      enable = true;
      catppuccin.enable = true;
    };

    boot.initrd.systemd.enable = true;
    boot.kernelParams = [ "quiet" "splash" ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      catppuccin.enable = true;
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
