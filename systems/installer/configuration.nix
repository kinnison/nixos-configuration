# This is the nixos installer for my stuff

{ modulesPath, homes, lib, config, ... }: {
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  system.stateVersion = "24.05";
  networking.hostName = "installer";
  kinnison.user = {
    name = "installer";
    home = homes.installer;
    extra = { initialPassword = "installer"; };
  };
  kinnison.gui = {
    enable = true;
    wayland.enable = true;
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

}
