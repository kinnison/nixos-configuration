{ pkgs, config, lib, ... }:
with lib;
let cfg = config.kinnison.sound;
in {
  options.kinnison.sound.spotify = mkEnableOption "Enable Spotify";

  config = mkIf cfg.spotify {
    home.packages = [ pkgs.spotify ];
    kinnison.unfree.pkgs = [ "spotify" ];
  };
}
