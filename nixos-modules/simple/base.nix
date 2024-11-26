# Base Role for all systems which I want
{ config, lib, pkgs, ... }:
with lib;
let unfreecfg = config.kinnison.unfree;
in {
  options.kinnison.unfree = {
    pkgs = mkOption {
      description = "Package names to permit in the unfree list";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = {
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
    };

    environment.pathsToLink = mkMerge [
      [ "/share/zsh" ]
      (mkIf config.kinnison.gui.enable [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ])
    ];

    # We pretty much always want SSH and can mkForce it off later if needs be
    services.sshd.enable = true;
    kinnison.impermanence.files = mkIf config.services.sshd.enable [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    # We are not prudish about non-free software for the most part,
    # though we do limit it, so here we list what's allowed
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) ([
        "vscode"
        "vscode-extension-ms-vscode-cpptools"
        "vscode-extension-ms-vscode-remote-remote-ssh"
        "vscode-extension-ms-vsliveshare-vsliveshare"
      ] ++ unfreecfg.pkgs);

    # Generally speaking, our systems need fstrim
    services.fstrim.enable = mkDefault true;

    # We like fwupd because it lets us have firmware updates
    services.fwupd.enable = mkDefault true;
    kinnison.impermanence.directories =
      [ "/var/lib/fwupd" "/var/cache/fwupd" "/var/cache/fwupdmgr" ];

    # We like vim and want it for the default editor (eww nano)
    programs.vim.defaultEditor = mkDefault true;
  };
}
