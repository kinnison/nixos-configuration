# Gaming stuff (eg minecraft)
{ osConfig, config, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.gaming;
in {
  options.kinnison.gaming = {
    minecraft = mkEnableOption "Enable Minecraft client";
    vintagestory = mkEnableOption "Enable VintageStory client";
  };

  config = mkMerge [
    (mkIf cfg.minecraft {
      assertions = [{
        assertion = osConfig.kinnison.gui.enable;
        message = "The minecraft client needs a gui to make sense";
      }];
      home.packages = with pkgs; [ prismlauncher ];
    })
    (mkIf cfg.vintagestory {
      assertions = [{
        assertion = osConfig.kinnison.gui.enable;
        message = "The vintagestory client needs a gui to make sense";
      }];
      home.packages = with pkgs; [ kinnison.vintagestory ];
      kinnison.unfree.pkgs = [ "vintagestory" ];
      kinnison.insecure.pkgs = [ "dotnet-runtime" ];
    })
  ];
}
