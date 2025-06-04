{ osConfig, pkgs, lib, ... }: {
  home.stateVersion = "24.11";
  # Turn on GnuPG if we have a gui enabled since that'll be needed for yubikeys etc.
  kinnison.gnupg.enable = osConfig.kinnison.gui.enable;
  # We default to having git available
  kinnison.git = {
    enable = true;
    email = "dsilvers@digital-scurf.org";
  };
  # I like rust, and I use helix instead of vscode to edit it
  kinnison.rust.enable = true;
  kinnison.vscode.enable = false;
  kinnison.helix.enable = true;
  # I use bitwarden for various things
  kinnison.bitwarden.enable = true;
  # If we have a gui turned on, I want IRC clients
  kinnison.irc.enable = osConfig.kinnison.gui.enable;
  # I want my email if I have a gui
  kinnison.email.enable = osConfig.kinnison.gui.enable;
  # I play minecraft, but only on my desktop typically
  kinnison.gaming.minecraft = osConfig.networking.hostName == "lassitude";
  # Playing VintageStory is fun, but needs a lot of faff.
  # For now, only on my desktop
  kinnison.gaming.vintagestory = osConfig.networking.hostName == "lassitude";
  # I do streaming, but only from my desktop typically
  kinnison.streaming.enable = osConfig.networking.hostName == "lassitude";

  # Keybase is something I only use on personal systems
  services.keybase.enable = true;
  home.packages = lib.mkMerge [
    (with pkgs; [ kinnison.juntakami kinnison.qxw ])
    # I like kicad, but only on my desktop for now
    (lib.mkIf (osConfig.networking.hostName == "lassitude") [ pkgs.kicad ])
  ];

  # I like Spotify for music
  kinnison.sound.spotify = true;

  programs.foot.settings.main.font =
    lib.mkIf (osConfig.networking.hostName == "catalepsy")
    (lib.mkForce "InconsolataNerdFont:size=14");
}
