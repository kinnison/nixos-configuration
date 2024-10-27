# The various Bitwarden related things
{ osConfig, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.bitwarden;
  guicfg = osConfig.kinnison.gui;
  pinentry-rofi = pkgs.kinnison.pinentry-rofi.override {
    rofi = config.programs.rofi.package;
  };
in {
  options.kinnison.bitwarden = {
    enable = mkEnableOption "Bitwarden Client(s)";
    vault = mkOption {
      description = "Vault URL";
      type = types.str;
      default = "https://vault.infrafish.uk/";
    };
    email = mkOption {
      description = "Email address";
      type = types.str;
      default = "dsilvers@digital-scurf.org";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.rbw = {
        enable = true;
        settings = {
          email = cfg.email;
          lock_timeout = 300;
          pinentry = pinentry-rofi;
          base_url = cfg.vault;
        };
      };
    })
    (mkIf (cfg.enable && guicfg.enable && guicfg.wayland.enable) {
      home.packages = [ pkgs.rofi-rbw-wayland ];
    })
    (mkIf (cfg.enable && guicfg.enable && !guicfg.wayland.enable) {
      home.packages = [ pkgs.rofi-rbw ];
    })
  ];
}

