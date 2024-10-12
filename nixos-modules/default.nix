# The various packages provided directly by my system and home configs
{ ... }: {
  imports = [ ./user.nix ./nm.nix ./simple ./gui ./sound ];
}
