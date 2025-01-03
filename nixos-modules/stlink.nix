{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.kinnison.stlink;
  stlink-udev = pkgs.kinnison.stlink-udev.override { group = cfg.group; };
in {
  options.kinnison.stlink = {
    enable = mkEnableOption "Turn on STLink capabilities";
    group = mkOption {
      type = types.str;
      description = "The group name to use for the stlink";
      default = "plugdev";
    };
  };

  config = mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    kinnison.user.groups = [ cfg.group ];
    services.udev.packages = [ stlink-udev ];
  };
}
