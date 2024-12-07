# This is the nixos installer for my stuff

{ modulesPath, homes, lib, config, pkgs, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ./systems.nix
  ];
  system.stateVersion = "24.11";
  networking.hostName = "installer";
  kinnison.user = {
    name = "nixos";
    realName = "NixOS Installer";
    home = homes.installer;
  };
  kinnison.gui = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = config.kinnison.user.name;
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.systemd.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = false;

  # If we run as a VM...
  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=1"
      "-display gtk,gl=off,show-cursor=off"
      "-m 4G"
    ];

    environment.sessionVariables = { WLR_NO_HARDWARE_CURSORS = "1"; };

    boot.kernelParams = [ "mitigations=off" ];
  };

  # Impermanence uses btrfs, so make sure we have it available
  environment.systemPackages = [ pkgs.btrfs-progs ];

  # Make the iso image less compressed for now, for speed
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}
