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
  };

  config = mkIf cfg.enable {
    boot.bootspec.enable = true;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = cfg.keysPath;
    };
    environment.systemPackages = [ pkgs.sbctl ];
    kinnison.impermanence.directories = mkIf imperm [ cfg.keysPath ];
  };
}
