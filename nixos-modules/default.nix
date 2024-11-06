# The various packages provided directly by my system and home configs
{ lib, ... }:
with lib; {
  imports = [ ./user.nix ./nm.nix ./simple ./gui ./sound ./bluetooth.nix ];

  options.kinnison.batteries = mkOption {
    description = "Batteries, if any";
    type = types.listOf types.str;
    default = [ ];
  };
}
