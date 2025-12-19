# Configuration for my personal laptop Catalepsy (was Cataplexy)

{ homes, ... }: rec {
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11";
  networking.hostName = "catalepsy";

  kinnison.user = {
    name = "dsilvers";
    realName = "Daniel Silverstone";
    home = homes.dsilvers;
    groups = [ "dialout" ];
    extra = {
      hashedPassword =
        "$6$jhPpRWgH6hEjTTmH$BZYw8lLV2lalgnsLdbm5r3JsZWxXwf/C7ldSqNaiz8i2xY/gHDEMmn4LK85MzSsOQOpbbZ334s90sPdCDDymH1";
    };
  };

  virtualisation.vmVariantWithBootLoader = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=1"
      "-display gtk,gl=off,show-cursor=off"
      "-m 8G"
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
  kinnison.secureboot.enable = true;
  kinnison.impermanence.enable = true;
  kinnison.virt-manager.enable = true;
  kinnison.gaming.steam = true;
  kinnison.stlink.enable = true;
}
