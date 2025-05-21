{ config, osConfig, lib, ... }:
with lib;
let cfg = config.kinnison.helix;
in {
  options.kinnison.helix = { enable = mkEnableOption "Helix editor"; };

  config = mkMerge [
    { kinnison.helix.enable = mkDefault true; }
    (mkIf cfg.enable {
      programs.helix = {
        enable = true;
        settings = {
          theme = mkForce "catppuccin-${osConfig.kinnison.gui.theme}";
          editor = {
            lsp = {
              display-inlay-hints = true;
              display-messages = true;
            };
            line-number = "absolute";
            mouse = false;
            rulers = [ 80 ];
            popup-border = "all";
            end-of-line-diagnostics = "hint";
            statusline = {
              left = [
                "mode"
                "spinner"
                "file-name"
                "version-control"
                "read-only-indicator"
                "file-modification-indicator"
              ];
              right = [
                "diagnostics"
                "selections"
                "position"
                "position-percentage"
                "file-encoding"
                "file-type"
              ];
            };
          };
        };
      };
    })
  ];
}
