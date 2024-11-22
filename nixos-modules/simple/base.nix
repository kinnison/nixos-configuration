# Base Role for all systems which I want
{ config, lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.cleanOnBoot = true;

  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
  environment.variables.LANG = lib.mkDefault "en_GB.UTF-8";
  console.keyMap = lib.mkDefault "uk";

  users = { defaultUserShell = pkgs.zsh; };

  security.sudo = {
    enable = lib.mkDefault true;
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

  environment.pathsToLink = lib.mkMerge [
    [ "/share/zsh" ]
    (lib.mkIf config.kinnison.gui.enable [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ])
  ];

  # We pretty much always want SSH and can mkForce it off later if needs be
  services.sshd.enable = true;
  kinnison.impermanence.files = lib.mkIf config.services.sshd.enable [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
  ];

  # We are not prudish about non-free software for the most part,
  # though we do limit it, so here we list what's allowed
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-ms-vscode-cpptools"
      "vscode-extension-ms-vscode-remote-remote-ssh"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];
}
