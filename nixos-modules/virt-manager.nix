# Virt-manager support
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.virt-manager;
in {
  options.kinnison.virt-manager = {
    enable =
      mkEnableOption "Virtualisation support with virt-manager and libvirtd";
    secureBoot = mkEnableOption "Enable Secure Boot UEFI firmware";
  };

  config = mkMerge [
    { kinnison.virt-manager.secureBoot = mkDefault true; }
    (mkIf cfg.enable {
      virtualisation.libvirtd = { enable = true; };
      environment.systemPackages = [ pkgs.virt-manager ];
      kinnison.user.groups = [ "libvirtd" ];

      # Libvirt stores information in various places
      kinnison.impermanence.directories =
        [ "/var/lib/libvirt" "/var/cache/libvirt" ];
    })
  ];
}
