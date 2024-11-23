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
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          ovmf.enable = true;
          ovmf.packages = [
            (mkIf cfg.secureBoot pkgs.OVMFFull.fd)
            (mkIf (!cfg.secureBoot) pkgs.OVMF.fd)
          ];
        };
      };
      environment.systemPackages = [ pkgs.virt-manager ];

      # Libvirt stores information in various places
      kinnison.impermanence.directories =
        [ "/var/lib/libvirt" "/var/cache/libvirt" ];
    })
  ];
}
