# Visual Studio Code configuration
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.kinnison.vscode;
  ra-exts = if config.kinnison.rust.enable then [{
    publisher = "rust-lang";
    name = "rust-analyzer";
    version = "0.4.1909";
    sha256 = "sha256-MHemPMdrkK5XxpnwEQYWIoqcf/x9n3sfD9xLzFDEstc=";
  }] else
    [ ];

  marketPlaceExtensions = ra-exts;
  allExtensions = with cfg.pkgs.vscode-extensions;
    [
      mkhl.direnv
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      ms-azuretools.vscode-docker
      ms-vsliveshare.vsliveshare
      jnoortheen.nix-ide
      brettm12345.nixfmt-vscode
      eamodio.gitlens
      usernamehw.errorlens
      tamasfe.even-better-toml
      esbenp.prettier-vscode
      zxh404.vscode-proto3
      vadimcn.vscode-lldb
      redhat.vscode-yaml
      catppuccin.catppuccin-vsc-icons
      catppuccin.catppuccin-vsc
    ] ++ (cfg.pkgs.vscode-utils.extensionsFromVscodeMarketplace
      marketPlaceExtensions);
in {
  options.kinnison.vscode = {
    enable = mkEnableOption "Visual Studio Code";
    pkgs = mkOption {
      description =
        "Place to find vscode-with-extensions and vscode-extensions";
      default = pkgs;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      stylix.targets.vscode.enable = false;
      home.packages = with pkgs; [ nixfmt-classic nodePackages.prettier nil ];
      programs.vscode = {
        enable = true;
        package = cfg.pkgs.vscode;
        extensions = allExtensions;
        userSettings = {
          "update.mode" = "none";
          "window.menuBarVisibility" = "toggle";
          "editor.minimap.enabled" = false;
          "editor.fontFamily" = mkForce
            "'Fira Code Sans Mono', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
          "editor.fontLigatures" = true;
          "editor.formatOnSave" = true;
          "editor.semanticHighlighting.enabled" = true;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          "workbench.editorAssociations" = { "*.ipynb" = "jupyter-notebook"; };
          "redhat.telemetry.enabled" = false;
          "[nix]" = {
            "editor.defaultFormatter" = "brettm12345.nixfmt-vscode";
          };
          "terminal.integrated.minimumContrastRatio" = 1;
          "window.zoomLevel" = 2;
          "window.titleBarStyle" = "native";
          "workbench.colorTheme" =
            "Catppuccin Mocha"; # In theory need to tweak this
          "workbench.iconTheme" = "catppuccin-mocha"; # Ditto
        };
      };
    })
    (mkIf (config.kinnison.rust.enable && cfg.enable) {
      programs.vscode.userSettings = {
        "rust-analyzer.server.path" =
          "${config.kinnison.rust.package}/bin/rust-analyzer";
        "rust-analyzer.check.command" = "clippy";
        "rust-analyzer.hover.actions.references.enable" = true;
        "rust-analyzer.inlayHints.closureReturnTypeHints.enable" = "with_block";
        "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "skip_trivial";
        "rust-analyzer.lens.references.adt.enable" = true;
        "rust-analyzer.lens.references.method.enable" = true;
        "rust-analyzer.lens.references.trait.enable" = true;
        "rust-analyzer.inlayHints.lifetimeElisionHints.useParameterNames" =
          true;
        "rust-analyzer.inlayHints.typeHints.hideClosureInitialization" = true;
        "rust-analyzer.inlayHints.typeHints.hideNamedConstructor" = true;
        "rust-analyzer.lru.capacity" = 512;
        "rust-analyzer.typing.autoClosingAngleBrackets.enable" = true;
      };
    })
  ];
}
