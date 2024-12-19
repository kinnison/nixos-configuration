# Gaming stuff (eg minecraft)
{ osConfig, config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.gaming;
in {
  options.kinnison.gaming = {
    minecraft = mkEnableOption "Enable Minecraft client";
  };

  config = mkIf cfg.minecraft {
    assertions = [{
      assertion = osConfig.kinnison.gui.enable;
      message = "The minecraft client needs a gui to make sense";
    }];
    home.packages = with pkgs; [ prismlauncher ];
  };
}
