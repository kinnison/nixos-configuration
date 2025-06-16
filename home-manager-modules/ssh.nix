{ ... }: {
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "60s";
  };
}
