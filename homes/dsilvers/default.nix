{ osConfig, ... }: {
  home.stateVersion = "24.05";
  # Turn on GnuPG if we have a gui enabled since that'll be needed for yubikeys etc.
  kinnison.gnupg.enable = osConfig.kinnison.gui.enable;
  # We default to having git available
  kinnison.git = {
    enable = true;
    email = "dsilvers@digital-scurf.org";
  };
  # I like rust, and I use vscode to edit it
  kinnison.rust.enable = true;
  kinnison.vscode.enable = true;
  # I use bitwarden for various things
  kinnison.bitwarden.enable = true;
}
