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

    powerManagement.cpuFreqGovernor = mkDefault "ondemand";

    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 85;
        START_CHARGE_THRESH_BAT1 = 70;
        STOP_CHARGE_THRESH_BAT1 = 85;
      };
    };

    # Turn on the extra governors
    boot.kernelModules =
      [ "cpufreq_ondemand" "cpufreq_powersave" "cpufreq_performance" ];

  };
}
