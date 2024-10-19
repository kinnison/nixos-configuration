# This is the nixos installer for my stuff

{ modulesPath, homes, lib, config, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ./systems.nix
  ];
  system.stateVersion = "24.05";
  networking.hostName = "installer";
  kinnison.user = {
    name = "nixos";
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
}
