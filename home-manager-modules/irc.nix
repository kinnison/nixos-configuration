# Support for Quassel IRC
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.irc;
in {
  options.kinnison.irc = { enable = mkEnableOption "IRC support"; };
  config = mkIf cfg.enable { home.packages = [ pkgs.quasselClient ]; };
}
