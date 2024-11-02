# My personal email configuration, on by default and primary by default
{ config, lib, ... }:
with lib;
let cfg = config.kinnison.email.personal;
in {
  options.kinnison.email.personal.enable = mkOption {
    type = types.bool;
    description = "Include personal email configuration";
    default = true;
  };

  config = mkIf cfg.enable {
    kinnison.email.accounts.home = {
      primary = true;
      realName = "Daniel Silverstone";
      address = "dsilvers@digital-scurf.org";
      userName = "dsilvers@digital-scurf.org";
      mailServer = "mail.infrafish.uk";
      displayFolders = [
        "Inbox"
        "listmaster"
        "Canonical"
        "Github"
        "Gitlab"
        "Family"
        "GPG"
        "RSS"
        "Lists"
        "Lists/Debian"
        "Lists/Debian/Devel-Announce"
        "Lists/Debian/UK"
        "Lists/Gitano"
        "Lists/Lua"
        "Lists/netsurf"
        "Lists/netsurf/commits"
        "Lists/netsurf/users"
        "Sent"
        "Old"
      ];
      watchFolders = [ "INBOX" "Github" "Gitlab" ];
      signature = ''
        Daniel Silverstone                         http://www.digital-scurf.org/
        PGP mail accepted and encouraged.            Key Id: 3CCE BABE 206C 3B69
      '';
    };
  };
}
