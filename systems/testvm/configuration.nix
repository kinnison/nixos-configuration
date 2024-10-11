{ pkgs, ... }:
let lib = pkgs.lib;
in rec {
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "24.05";
  networking.hostName = "testvm";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
  console.keyMap = lib.mkDefault "uk";

  #nix = {
  #  package = pkgs.nixFlakes;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  #  settings = { auto-optimise-store = true; };
  #};

  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "networkmanager" ];
    initialPassword = "test";
  };
  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    dunst
    libnotify
    rofi-wayland
    firefox
    networkmanagerapplet
    shikane
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  sound.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };

  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" "splash" ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  #services.greetd.enable = true;
  #programs.regreet.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    fira-code-symbols
    inconsolata
    font-awesome
    (nerdfonts.override {
      fonts = [ "FiraCode" "DroidSansMono" "Inconsolata" ];
    })
  ];

  virtualisation.vmVariantWithBootLoader = {
    virtualisation.qemu.options = [
      "-device virtio-vga,max_outputs=2"
      "-display gtk,gl=off,show-cursor=off"
    ];

    environment.sessionVariables =
      pkgs.lib.mkVMOverride { WLR_NO_HARDWARE_CURSORS = "1"; };
  };

  virtualisation.vmVariant = virtualisation.vmVariantWithBootLoader;

  hardware.opengl.enable = true;
}
