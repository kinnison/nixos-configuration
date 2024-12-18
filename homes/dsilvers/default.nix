{ osConfig, pkgs, ... }: {
  home.stateVersion = "24.11";
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
  # If we have a gui turned on, I want IRC clients
  kinnison.irc.enable = osConfig.kinnison.gui.enable;
  # I want my email if I have a gui
  kinnison.email.enable = osConfig.kinnison.gui.enable;

  # Keybase is something I only use on personal systems
  services.keybase.enable = true;
  home.packages = with pkgs; [ kinnison.juntakami ];
}
