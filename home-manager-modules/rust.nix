# Rust configuration for home directory
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.rust;
  dataHome = config.xdg.dataHome;
  hasHelix = config.kinnison.helix.enable;
  rust-lldb-dap = pkgs.writeShellScript "rust-lldb-dap" ''
    LLDB_DAP="${pkgs.lldb_20}/bin/lldb-dap"
    SYSROOT="$(rustc --print sysroot)"
    ETC="''${SYSROOT}/lib/rustlib/etc"

    exec "''${LLDB_DAP}" \
      --pre-init-command "command script import \"''${ETC}/lldb_lookup.py\"" \
      --pre-init-command "command source -s 0 \"''${ETC}/lldb_commands\"" \
      "$@"
  '';
in {
  options.kinnison.rust = {
    enable = mkEnableOption "Rust (via rustup)";
    package = mkOption {
      description = "Package for rustup";
      type = types.package;
      default = pkgs.rustup;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = [ cfg.package ];
      home.sessionVariables = {
        RUSTUP_HOME = "${dataHome}/rustup";
        CARGO_HOME = "${dataHome}/cargo";
      };
      home.sessionPath = [ "${dataHome}/cargo/bin" ];
    })
    (mkIf (cfg.enable && hasHelix) {
      programs.helix.languages = {
        language = [{
          name = "rust";
          debugger = {
            name = "rust-lldb-dap";
            transport = "stdio";
            command = "${rust-lldb-dap}";
            templates = [{
              name = "binary";
              request = "launch";
              completion = [{
                name = "binary";
                completion = "filename";
              }];
              args = { program = "{0}"; };
            }];
          };
        }];
        language-server.rust-analyzer.config = {
          assist.emitMustUse = true;
          cargo = {
            buildScripts.enable = true;
            allTargets = true;
          };
          check = {
            allTargets = true;
            command = "clippy";
            workspace = true;
          };
          diagnostics.styleLints.enable = true;
          inlayHints = {
            closureCaptureHints.enable = true;
            closureReturnTypeHints.enable = true;
            implicitDrops.enable = false;
            lifetimeElisionHints.enable = true;
            lifetimeElisionHints.useParameterNames = true;
            maxLength = 40;
          };
          lens = {
            enable = true;
            references = {
              adt.enable = true;
              enumVariant.enable = true;
              trait.enable = true;
              run.enable = false;
            };
          };
          procMacro = {
            enable = true;
            attributes.enable = true;
          };
          imports = {
            granularity = {
              enforce = false;
              group = "crate";
            };
            group.enable = true;
            merge.glob = true;
            preferNoStd = false;
            preferPrelude = true;
            prefix = "crate";
            prefixExternInclude = false;
          };
        };
      };
    })
  ];
}
