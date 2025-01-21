{ config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.docker;
in {
  options.kinnison.docker = { enable = mkEnableOption "Docker support"; };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
    environment.systemPackages = with pkgs; [ crun docker-compose ];
    kinnison.impermanence.directories = [ "/var/lib/docker" ];
  };
}
