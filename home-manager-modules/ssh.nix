{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ControlMaster = "auto";
      ControlPersist = "60s";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 15;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
    };
  };
}
