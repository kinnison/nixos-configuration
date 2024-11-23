{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  kinnison.batteries = [ "BAT0" "BAT1" ];

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
  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Disk setup
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
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
                name = "catacrypt";
                askPassword = true;
                settings = { allowDiscards = true; };
                content = {
                  type = "lvm_pv";
                  vg = "catavg";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      catavg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "5G";
            content = {
              type = "btrfs";
              extraArgs = [ "-f " ];
              subvolumes = {
                "/root-blank" = { };
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "defaults" "relatime" ];
                };
              };
            };
          };
          persist = {
            size = "20G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
              mountOptions = [ "defaults" "relatime" ];
            };
          };
          nix = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
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
