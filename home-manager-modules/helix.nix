{ config, osConfig, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.helix;
in {
  options.kinnison.helix = { enable = mkEnableOption "Helix editor"; };

  config = mkMerge [
    { kinnison.helix.enable = mkDefault true; }
    (mkIf cfg.enable {
      programs.vim.defaultEditor = mkForce false;
      programs.helix = {
        enable = true;
        package = pkgs.kinnison.helix;
        defaultEditor = true;
        languages = {
          language = [{
            name = "mail";
            file-types = [{ glob = "neomutt-*"; }];
          }];
        };
        settings = {
          theme = mkForce "catppuccin-${osConfig.kinnison.gui.theme}";
          editor = {
            bufferline = "always";
            lsp = {
              display-inlay-hints = true;
              display-messages = true;
            };
            line-number = "absolute";
            mouse = false;
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
