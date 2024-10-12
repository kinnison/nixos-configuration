# Base Role for all systems which I want
{ config, lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
  environment.variables.LANG = lib.mkDefault "en_GB.UTF-8";
  console.keyMap = lib.mkDefault "uk";

  users = { defaultUserShell = pkgs.zsh; };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
}