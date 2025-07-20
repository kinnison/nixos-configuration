# The various packages provided directly by my system and home configs
{ lib, pkgs, osConfig, config, ... }:
let
  inherit (lib) mkMerge mkIf mkForce;
  guicfg = osConfig.kinnison.gui;
  nmcfg = osConfig.kinnison.network-manager;
  bluecfg = osConfig.kinnison.bluetooth;
  sndcfg = osConfig.kinnison.sound;
  mkUpper = str:
    (lib.toUpper (builtins.substring 0 1 str))
    + (builtins.substring 1 (builtins.stringLength str) str);
  cursor-name = "${guicfg.theme}${mkUpper guicfg.accent}";
  catppuccin-sources-names =
    builtins.map (n: config.catppuccin.sources.${n}) [ "rofi" ];
  closure = pkgs.closureInfo {
    rootPaths = builtins.map (s: s.outPath) catppuccin-sources-names;
  };
in {
  imports = [
    ./bitwarden.nix
    ./git.nix
    ./gpg.nix
    ./irc.nix
    ./mail.nix
    ./mail-personal.nix
    ./rust.nix
    ./vscode.nix
    ./wayland.nix
    ./gaming.nix
    ./spotify.nix
    ./streaming.nix
    ./helix.nix
    ./ssh.nix
  ];
  config = mkMerge [
    {
      # We use attic in order to access our cache management
      home.packages = [ pkgs.attic-client ];
    }
    (mkIf guicfg.enable {
      catppuccin = {
        enable = true;
        flavor = guicfg.theme;
        accent = guicfg.accent;
        #pointerCursor.enable = true;
      };
      # https://github.com/catppuccin/gtk/issues/262
      # Essentially don't bother - GTK is impossible to theme properly
      # unless you're GNOME
      #gtk.catppuccin = {
      #  enable = true;
      #  icon.enable = true;
      #};
      gtk.enable = true;
      qt.enable = true;
      catppuccin.kvantum.enable = false;
      home.pointerCursor = {
        name = mkForce "catppuccin-${guicfg.theme}-${guicfg.accent}-cursors";
        package = mkForce pkgs.catppuccin-cursors.${cursor-name};
        size = mkForce 16;
      };
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        settings = {
          device_config = [{
            device_file = "/dev/fd0";
            ignore = true;
          }];
        };
      };
      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };
      home.packages = [ pkgs.libsecret pkgs.firefox closure ];
    })
    (mkIf (guicfg.enable && bluecfg.enable) {
      services.blueman-applet.enable = true;
    })
    (mkIf (guicfg.enable && sndcfg.enable) {
      home.packages = [ pkgs.pavucontrol ];
    })
    (mkIf nmcfg.enable { services.network-manager-applet.enable = true; })
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion = {
          enable = true;
          strategy = [ "history" "match_prev_cmd" "completion" ];
        };
        history = {
          append = true;
          share = true;
          extended = true;
          ignoreAllDups = true;
          ignoreSpace = true;
        };
        syntaxHighlighting.enable = true;
        defaultKeymap = "emacs";
        shellAliases.vi = "hx";
      };
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = { enable = true; };
      };

      programs.vim = {
        enable = true;
        settings = { background = "dark"; };
        extraConfig = ''
          set mouse=
        '';
        defaultEditor = true;
      };
      xdg = {
        enable = true;
        mimeApps.enable = true;
      };
      home.packages = [ pkgs.at-spi2-atk ];
    }
  ];
}
