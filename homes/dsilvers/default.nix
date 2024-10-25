{ osConfig, ... }: {
  home.stateVersion = "24.05";
  # Turn on GnuPG if we have a gui enabled since that'll be needed for yubikeys etc.
  kinnison.gnupg.enable = osConfig.kinnison.gui.enable;
  # We default to having git available
  kinnison.git = {
    enable = true;
    email = "dsilvers@digital-scurf.org";
  };
}
