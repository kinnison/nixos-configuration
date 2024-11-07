{ config, lib, ... }:
with lib;
let batcfg = config.kinnison.batteries;
in {
  options.kinnison.batteries = mkOption {
    description = "Batteries, if any";
    type = types.listOf types.str;
    default = [ ];
  };

  config = mkIf (batcfg != [ ]) {
    services.upower = {
      enable = true;
      timeLow = 600; # 10 minutes
      timeCritical = 300; # 5 minutes
      timeAction = 120; # 2 minutes
      percentageLow = 10;
      percentageCritical = 5;
      percentageAction = 2;
      criticalPowerAction = "PowerOff";
    };
  };
}
