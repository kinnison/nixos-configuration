{ config, osConfig, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.streaming;
  guicfg = osConfig.kinnison.gui;
  plugins = pkgs.obs-studio-plugins;
in {
  options.kinnison.streaming = {
    enable = mkEnableOption "Streaming capability such as obs-studio";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = mkMerge [
        (mkIf guicfg.wayland.enable [ plugins.wlrobs ])
        [
          plugins.input-overlay
          plugins.obs-move-transition
          plugins.obs-pipewire-audio-capture

        ]
      ];
    };
  };
}

