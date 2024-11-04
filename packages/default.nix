# The various packages provided directly by my system and home configs
{ pkgs }: {
  rofi-lock = pkgs.callPackage ./rofi-lock { };
  pinentry-rofi = pkgs.callPackage ./pinentry-rofi { };
  capture = pkgs.callPackage ./capture { };
}
