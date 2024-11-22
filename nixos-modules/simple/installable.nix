{ config, lib, ... }:
with lib; {
  options.kinnison.installer-image =
    mkEnableOption "Configure this for the installer";

  config = mkIf config.kinnison.installer-image {
    # If we have secureboot enabled for the installer, turn it off
    kinnison.secureboot.installMode = true;
  };
}
