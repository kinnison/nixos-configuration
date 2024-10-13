{ pkgs, homes, ... }:
let lib = pkgs.lib;
in rec {
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "24.05";
  networking.hostName = "testvm";

  #users.users.test = {
  #  isNormalUser = true;
  #  extraGroups = [ "wheel" "input" "networkmanager" ];
  #  initialPassword = "test";
  #};

  kinnison.user = {
    name = "test";
    home = homes.dsilvers;
    extra = { initialPassword = "test"; };
  };

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    dunst
    libnotify
    rofi-wayland
    firefox
    networkmanagerapplet
    shikane
    quasselClient
  ];

  virtualisation.vmVariantWithBootLoader = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=1"
      "-display gtk,gl=off,show-cursor=off"
    ];

    environment.sessionVariables =
      pkgs.lib.mkVMOverride { WLR_NO_HARDWARE_CURSORS = "1"; };
  };

  virtualisation.vmVariant = virtualisation.vmVariantWithBootLoader;

  kinnison.gui = {
    enable = true;
    wayland.enable = true;
  };
  kinnison.sound.enable = true;
  kinnison.network-manager.enable = true;
}
