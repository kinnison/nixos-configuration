# Configuration for my personal laptop Catalepsy (was Cataplexy)

{ pkgs, homes, ... }: rec {
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11";
  networking.hostName = "lassitude";

  kinnison.user = {
    name = "dsilvers";
    realName = "Daniel Silverstone";
    home = homes.dsilvers;
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
    wayland.extraSwayConfig = {
      output."HDMI-A-1" = {
        mode = "1920x1080@60Hz";
        pos = "0 0";
        transform = "normal";
      };
      output."DP-1" = {
        mode = "1920x1080@60Hz";
        pos = "1920 0";
        transform = "normal";
      };
      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "HDMI-A-1";
        }
        {
          workspace = "2";
          output = "DP-1";
        }
      ];
    };
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;
  kinnison.secureboot.enable = true;
  kinnison.impermanence.enable = true;
  kinnison.virt-manager.enable = true;
  kinnison.docker.enable = true;
  kinnison.gaming.steam = true;

  # Printing at home uses HP
  kinnison.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # We use stlinks on our desktop
  kinnison.stlink.enable = true;
}
