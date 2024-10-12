# Sound configuration etc.
{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.kinnison.sound;
in {
  options.kinnison.sound = { enable = mkEnableOption "System sound support"; };

  config = mkIf cfg.enable {
    sound.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
