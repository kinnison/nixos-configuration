# Printing setup for CUPS etc.
{ pkgs, config, lib, ... }:
with lib;
let cfg = config.kinnison.printing;
in {
  options.kinnison.printing = {
    enable = mkEnableOption "Printing with CUPS etc.";
    drivers = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression "with pkgs; [ hplip ]";
      description = "Extra drivers to add to CUPS, eg hplip";
    };
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      browsed.enable = true;
      drivers = cfg.drivers;
    };

    services.system-config-printer.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    environment.systemPackages = with pkgs; [ system-config-printer ];

    kinnison.impermanence.directories =
      [ "/var/cache/cups" "/var/spool/cups" "/var/lib/cups" ];
  };
}
