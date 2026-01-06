{ pkgs, config, lib, ... }:
with lib;
let cfg = config.kinnison.sound;
in {
  options.kinnison.sound.plexamp = mkEnableOption "Enable Plexamp";

  config = mkIf cfg.plexamp {
    home.packages = [ pkgs.plexamp ];
    kinnison.unfree.pkgs = [ "plexamp" ];
  };
}
