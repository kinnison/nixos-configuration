# Wayland GUI setup
{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkForce;
  cfg = config.kinnison.gui.wayland;
  enable = config.kinnison.gui.enable && cfg.enable;
  autoLogin = config.kinnison.user.autoLogin;
  autoLoginUser = config.kinnison.user.name;
in {
  options.kinnison.gui.wayland = { enable = mkEnableOption "Wayland GUI"; };

  config = mkIf enable (mkMerge [
    {
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
        catppuccin.fontSize = "18";
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

      environment.systemPackages = with pkgs; [ swayosd ];

      services.udev.packages = [ pkgs.swayosd ];

      hardware.opengl.enable = true;

      kinnison.user.groups = [ "input" ];
      kinnison.impermanence.directories =
        [ "/var/lib/sddm" "/var/lib/plymouth" ];
    }
    (mkIf autoLogin {
      services.displayManager.autoLogin = {
        enable = true;
        user = autoLoginUser;
      };
      # Adding this doesn't harm the non-encrypted case and helps with
      # encrypted disk unlock leading to keyring unlock
      systemd.services.display-manager.serviceConfig.KeyringMode = "inherit";
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.sddm-autologin.text = mkForce ''
        auth     requisite pam_nologin.so
        auth     required  pam_succeed_if.so uid >= ${
          toString config.services.displayManager.sddm.autoLogin.minimumUid
        } quiet
        auth     optional  ${pkgs.systemd}/lib/security/pam_systemd_loadkey.so
        auth     optional  ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
        auth     required  pam_permit.so

        account  include   sddm

        password include   sddm

        session  include   sddm
      '';
    })
  ]);
}
