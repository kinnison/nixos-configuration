# Impermanence core support
{ config, lib, ... }:
with lib;
let
  cfg = config.kinnison.impermanence;
  root-device = removePrefix "/" config.fileSystems."/".device;
  root-device' = replaceStrings [ "/" ] [ "-" ] root-device;
  root-device-service = "${root-device'}.device";
  root-reset-src-raw = builtins.readFile ./impermanence-root-reset.sh;
  root-reset-src =
    replaceStrings [ "@ROOT_DEVICE@" ] [ config.fileSystems."/".device ]
    root-reset-src-raw;
in {
  options.kinnison.impermanence = {
    enable = mkEnableOption "Impermanence support";
    persistentBase = mkOption {
      description = "Default persistence basis";
      default = "/persist";
      type = types.str;
    };
    directories = mkOption {
      description = "Directories to persist";
      type = types.listOf types.str;
      default = [ ];
    };
    files = mkOption {
      description = "Files to persist under persistentBase";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.fileSystems ? ${cfg.persistentBase};
        message =
          "kinnison.impermanence.persistentBase is `${cfg.persistentBase}` but that is not a filesystem";
      }
      {
        assertion = config.fileSystems."/".fsType == "btrfs";
        message = "kinnison.impermanence is only supported if / is btrfs";
      }
    ];

    fileSystems."/".neededForBoot = true;
    fileSystems."${cfg.persistentBase}".neededForBoot = true;

    boot.initrd.systemd.enable = mkDefault true;
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to pristine state";
      wantedBy = [ "initrd.target" ];
      after = [ root-device-service ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = root-reset-src;
    };
    boot.initrd.systemd.services.persisted-files = {
      description = "Bring in /etc/machine-id from ${cfg.persistentBase}";
      wantedBy = [ "initrd.target" ];
      after = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /sysroot/etc
        ln -snfT ${cfg.persistentBase}/etc/machine-id /sysroot/etc/machine-id
      '';
    };

    environment.persistence."${cfg.persistentBase}" = {
      directories = cfg.directories ++ [
        # These are essential to functioning really
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];
      files = cfg.files;
    };
  };
}
