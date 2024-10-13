{ pkgs, homes, ... }: rec {
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "24.05";
  networking.hostName = "testvm";

  kinnison.user = {
    name = "test";
    home = homes.dsilvers;
    extra = { initialPassword = "test"; };
  };

  environment.systemPackages = with pkgs; [ firefox quasselClient ];

  virtualisation.vmVariantWithBootLoader = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=1"
      "-display gtk,gl=off,show-cursor=off"
      "-m 4G"
    ];

    environment.sessionVariables =
      pkgs.lib.mkVMOverride { WLR_NO_HARDWARE_CURSORS = "1"; };

    boot.kernelParams = [ "mitigations=off" ];
  };

  virtualisation.vmVariant = virtualisation.vmVariantWithBootLoader;

  kinnison.gui = {
    enable = true;
    wayland.enable = true;
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;
}
