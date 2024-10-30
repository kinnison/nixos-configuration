# This is the "hardware" configuration for a basic test VM
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "virtio_gpu"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "testcrypt";
                askPassword = true;
                settings = { allowDiscards = true; };
                content = {
                  type = "lvm_pv";
                  vg = "testvg";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      testvg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "20G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" "relatime" ];
            };
          };
          home = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
              mountOptions = [ "defaults" "relatime" ];
            };
          };
        };
      };
    };
  };
}
