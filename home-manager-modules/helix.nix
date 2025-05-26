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
          language = [
            {
              name = "mail";
              file-types = [{ glob = "neomutt-*"; }];
              language-servers = [ "hanumail" ];
              rulers = [ 78 ];
            }
            {
              name = "nix";
              auto-format = true;
              formatter = { command = "${pkgs.nixfmt-classic}/bin/nixfmt"; };
            }
          ];
          language-server.hanumail = {
            command = "${pkgs.kinnison.hanumail}/bin/hanumail";
          };
        };
        settings = {
          theme = mkForce "catppuccin-${osConfig.kinnison.gui.theme}";
          editor = {
            bufferline = "always";
            lsp = {
              enable = true;
              display-messages = true;
              display-progress-messages = true;
              auto-signature-help = true;
              display-inlay-hints = true;
              display-signature-help-docs = true;
            };
            end-of-line-diagnostics = "hint";
            inline-diagnostics = {
              cursor-line = "warning";
              other-lines = "error";
            };
            line-number = "absolute";
            mouse = false;
            popup-border = "all";
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
              mode = {
                normal = "CMD";
                insert = "INS";
                select = "SEL";
              };
            };
            completion-replace = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            whitespace = {
              render = {
                space = "none";
                tab = "all";
                nbsp = "none";
                nnbsp = "none";
                newline = "none";
              };
              characters = {
                space = "·";
                nbsp = "⍽";
                nnbsp = "␣";
                tab = "→";
                newline = "⏎";
                tabpad = "·";
              };
            };
            indent-guides = {
              render = true;
              #character = "⸽";
              skip-levels = 0;
            };
          };
          keys = {
            insert = {
              "C-space" = "code_action";
              "C-." = "completion";
              "C-left" = "move_prev_word_start";
              "C-right" = "move_next_word_end";
              "C-S-left" = "extend_prev_word_start";
              "C-S-right" = "extend_next_word_end";
            };
          };
        };
      };
    })
  ];
}
