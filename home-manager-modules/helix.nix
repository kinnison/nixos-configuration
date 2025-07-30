{ config, osConfig, lib, pkgs, ... }:
with lib;
let cfg = config.kinnison.helix;
in {
  options.kinnison.helix = {
    enable = mkEnableOption "Helix editor";
    harper = { enable = mkEnableOption "Harper spell/grammar checker"; };
  };

  config = mkMerge [
    {
      kinnison.helix.enable = mkDefault true;
      kinnison.helix.harper.enable = mkDefault true;
    }
    (mkIf cfg.enable {
      programs.ssh.matchBlocks."*" = { sendEnv = [ "COLORTERM" ]; };
      programs.vim.defaultEditor = mkForce false;
      programs.helix = {
        enable = true;
        package = pkgs.kinnison.helix;
        defaultEditor = true;
        languages = {
          language = [{
            name = "nix";
            auto-format = true;
            formatter = { command = "${pkgs.nixfmt-classic}/bin/nixfmt"; };
          }];
          language-server.nil = { command = "${pkgs.nil}/bin/nil"; };
        };
        settings = {
          theme = mkForce "catppuccin-${osConfig.kinnison.gui.theme}";
          editor = {
            trim-final-newlines = true;
            trim-trailing-whitespace = true;
            editor-config = true;
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
                "register"
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
            preview-completion-insert = false;
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
              # Reflow like emacs
              "A-q" = "@<esc>mip:reflow<ret><right>i";
            };
            normal = {
              # Reflow like emacs
              "A-q" = "@mip:reflow<ret><right>";
              "H" = "goto_line_start";
              "^" = "goto_line_start";
              "L" = "goto_line_end";
              "$" = "goto_line_end";
            };
          };
        };
      };
    })
    (mkIf cfg.harper.enable {
      programs.helix.languages = {
        language-server.harper-ls = {
          command = "${pkgs.harper}/bin/harper-ls";
          # This needs a newer harper than we currently have
          # args = [ "--stdio" "--skip-version-check" ];
          config = {
            harper-ls = {
              dialect = "British";
              linters = {
                # This is critical
                OxfordComma = true;
                NoOxfordComma = false;
                # Since most stuff is comments, turn off these
                ToDoHyphen = false;
                ExpandWith = false;
                ExpandWithout = false;
              };
              codeActions.ForceStable = true;
            };
          };
        };
        language = [
          {
            name = "markdown";
            language-servers = [ "markdown-oxide" "marksman" "harper-ls" ];
          }
          {
            name = "nix";
            language-servers = [ "nil" "harper-ls" ];
          }
          (mkIf config.kinnison.rust.enable {
            name = "rust";
            language-servers = [ "rust-analyzer" "harper-ls" ];
          })
          (mkIf config.kinnison.git.enable {
            name = "git-commit";
            language-servers = [ "harper-ls" ];
          })
        ];
      };
    })
  ];
}
