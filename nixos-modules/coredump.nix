{ config, lib, ... }:
let cfg = config.kinnison.coredump;

in with lib; {
  options.kinnison.coredump = {
    enable = mkEnableOption "Dump cores persistently with systemd-coredump";
  };
  config = mkMerge [
    { kinnison.coredump.enable = mkDefault false; }
    (mkIf (!cfg.enable) {
      # Try and turn off coredumps
      systemd.coredump.extraConfig = ''
        Storage=none
        ProcessSizeMax=0
      '';
    })
    (mkIf cfg.enable {
      # Coredumps but only for reasonably sized things
      systemd.coredump.extraConfig = ''
        Storage=enable
        Compress=yes
        ProcessSizeMax=8G
        MaxUse=8G
      '';
    })
  ];
}
