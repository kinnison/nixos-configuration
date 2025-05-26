# Home-Manager GnuPG configuration
{ lib, osConfig, config, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.gnupg;
  pinentry-rofi = pkgs.kinnison.pinentry-rofi.override {
    rofi = config.programs.rofi.package;
  };
in {
  options.kinnison.gnupg = { enable = mkEnableOption "GnuPG Support"; };

  config = mkIf cfg.enable {
    services.gpg-agent = {
      enable = true;
      enableScDaemon = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentry.package =
        mkIf osConfig.kinnison.gui.wayland.enable pinentry-rofi;
      verbose = true;
    };
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
      mutableKeys = true;
      mutableTrust = true;
      publicKeys = [{
        source = ./daniel.pubkey;
        trust = "ultimate";
      }];
    };
  };
}
