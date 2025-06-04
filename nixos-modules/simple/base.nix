# Base Role for all systems which I want
{ config, lib, pkgs, ... }:
with lib;
let
  unfreecfg = config.kinnison.unfree;
  insecurecfg = config.kinnison.insecure;
  all-user-unfree-pkgs' = mapAttrsToList (name: conf: conf.kinnison.unfree.pkgs)
    config.home-manager.users;
  all-user-unfree-pkgs = flatten all-user-unfree-pkgs';
  all-user-insecure-pkgs' =
    mapAttrsToList (name: conf: conf.kinnison.insecure.pkgs)
    config.home-manager.users;
  all-user-insecure-pkgs = flatten all-user-insecure-pkgs';
in {
  options.kinnison.unfree = {
    pkgs = mkOption {
      description = "Package names to permit in the unfree list";
      type = types.listOf types.str;
      default = [ ];
    };
  };
  options.kinnison.insecure = {
    pkgs = mkOption {
      description = "Package names to permit in the insecure list";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = {

    home-manager.sharedModules = [{
      options.kinnison.unfree = {
        pkgs = mkOption {
          description = "Package names to permit in the unfree list";
          type = types.listOf types.str;
          default = [ ];
        };
      };
      options.kinnison.insecure = {
        pkgs = mkOption {
          description = "Package names to permit in the inscure list";
          type = types.listOf types.str;
          default = [ ];
        };
      };
    }];

    boot.loader.systemd-boot.enable = mkDefault true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.tmp.cleanOnBoot = true;

    time.timeZone = mkDefault "Europe/London";
    i18n.defaultLocale = mkDefault "en_GB.UTF-8";
    environment.variables.LANG = mkDefault "en_GB.UTF-8";
    console.keyMap = mkDefault "uk";

    users = { defaultUserShell = pkgs.zsh; };

    security.sudo = {
      enable = mkDefault true;
      extraConfig = ''
        Defaults lecture = never
      '';
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      promptInit = ''
        eval "$(${pkgs.kinnison.prompter}/bin/prompter init)"
      '';
      interactiveShellInit = ''
        # Extended globbing
        setopt extended_glob
        # zsh: exit 1 stylee stuff
        setopt print_exit_value
        # turn off annoying vim style tab completion
        setopt no_auto_menu
        # Enable partial list style completion
        zstyle ':completion:*' list-suffixes true
        # Bash-style null glob result -> no error
        setopt null_glob
        # Comments in the shell prompt are permitted
        setopt interactivecomments
        # Remove / from the default WORDCHARS
        WORDCHARS=$(echo $WORDCHARS | tr -d '/')
        # Report if a command takes > 10s to run
        REPORTTIME=10
      '';
    };

    environment.pathsToLink = mkMerge [
      [ "/share/zsh" ]
      (mkIf config.kinnison.gui.enable [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ])
    ];

    # We pretty much always want SSH and can mkForce it off later if needs be
    services.openssh = {
      enable = true;
      extraConfig = ''
        AcceptEnv COLORTERM
      '';
    };
    kinnison.impermanence.files = mkIf config.services.sshd.enable [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    # We are not prudish about non-free software for the most part,
    # though we do limit it, so here we list what's allowed
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) (unfreecfg.pkgs ++ all-user-unfree-pkgs);
    # Ditto "insecure" software
    nixpkgs.config.allowInsecurePredicate = pkg:
      builtins.elem (getName pkg) (insecurecfg.pkgs ++ all-user-insecure-pkgs);

    # Generally speaking, our systems need fstrim
    services.fstrim.enable = mkDefault true;

    # We like fwupd because it lets us have firmware updates
    services.fwupd.enable = mkDefault true;
    kinnison.impermanence.directories =
      [ "/var/lib/fwupd" "/var/cache/fwupd" "/var/cache/fwupdmgr" ];

    # We like vim and want it for the default editor (eww nano)
    programs.vim = {
      enable = mkDefault true;
      defaultEditor = mkDefault (config.programs.vim.enable);
    };

    # It's always OK for the user to run dmesg IMO
    boot.kernel.sysctl."kernel.dmesg_restrict" = false;
  };
}
