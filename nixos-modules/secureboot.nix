{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.secureboot;
  imperm = config.kinnison.impermanence.enable;
in {
  options.kinnison.secureboot = {
    enable = mkEnableOption "Secure boot with Lanzaboote";

    keysPath = mkOption {
      description = "Path to the place to store secureboot keys";
      type = types.str;
      default = "/etc/secureboot";
    };

    installMode = mkEnableOption "Prevent the bootloader change";
  };

  config = mkIf cfg.enable {
    boot.bootspec.enable = true;
    boot.loader.systemd-boot.enable = mkIf (!cfg.installMode) (mkForce false);
    boot.lanzaboote = {
      enable = !cfg.installMode;
      pkiBundle = cfg.keysPath;
    };
    environment.systemPackages =
      [ pkgs.sbctl (mkIf cfg.installMode config.boot.lanzaboote.package) ];
    kinnison.impermanence.directories = mkIf imperm [ cfg.keysPath ];
  };
}
