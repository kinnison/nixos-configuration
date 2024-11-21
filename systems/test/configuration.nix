{ homes, lib, ... }:
let inherit (lib) mkDefault;
in rec {
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "24.05";
  networking.hostName = "test";

  kinnison.user = {
    name = "test";
    realName = "Testy McTestface";
    home = homes.dsilvers;
    extra = { initialPassword = "test"; };
  };

  virtualisation.vmVariantWithBootLoader = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=1"
      "-display gtk,gl=off,show-cursor=off"
      "-m 4G"
    ];

    environment.sessionVariables = { WLR_NO_HARDWARE_CURSORS = "1"; };

    boot.kernelParams = [ "mitigations=off" ];
    virtualisation.diskSize = 5120;
  };

  virtualisation.vmVariant = virtualisation.vmVariantWithBootLoader;
  virtualisation.vmVariantWithDisko = virtualisation.vmVariant;

  kinnison.gui = {
    enable = true;
    wayland.enable = true;
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;

  kinnison.secureboot.enable = mkDefault true;
}
