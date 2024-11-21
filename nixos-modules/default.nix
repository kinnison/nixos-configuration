# The various packages provided directly by my system and home configs
{ lib, config, ... }:
with lib;
let zram = config.kinnison.zram;
in {
  imports = [
    ./user.nix
    ./nm.nix
    ./simple
    ./gui
    ./sound
    ./bluetooth.nix
    ./power.nix
    ./secureboot.nix
    ./impermanence.nix
  ];

  options.kinnison.zram = {
    enable = mkEnableOption "Turn on zram";
    percent = mkOption {
      type = types.int;
      default = 50;
      description = "Percentage of RAM to permit to be zram swap";
    };
  };

  config = mkMerge [
    { kinnison.zram.enable = mkDefault true; }
    (mkIf zram.enable {
      zramSwap = {
        enable = true;
        memoryPercent = zram.percent;
      };
    })
  ];
}
