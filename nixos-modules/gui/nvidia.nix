{ config, lib, ... }:
with lib;
let cfg = config.kinnison.nvidia;

in {
  options.kinnison.nvidia.enable = mkEnableOption "Nvidia GPU";

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    # Seems dumb but hardware.nvidia requires it?
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    kinnison.unfree.pkgs = [ "nvidia-x11" "nvidia-settings" ];
  };
}
