{ osConfig, ... }: {
  home.stateVersion = "24.05";
  # Turn on GnuPG if we have a gui enabled since that'll be needed for yubikeys etc.
  kinnison.gnupg.enable = osConfig.kinnison.gui.enable;
}
