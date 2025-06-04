# The various packages provided directly by my system and home configs
{ pkgs }:
let

  is_system_build = pkgs ? kinnison;

  only_system_pkgs = {

    vintagestory = pkgs.callPackage ./upstream/vintagestory.nix { };
  };

  append_pkgs = if is_system_build then only_system_pkgs else { };

in {
  rofi-lock = pkgs.callPackage ./rofi-lock { };
  pinentry-rofi = pkgs.callPackage ./pinentry-rofi { };
  capture = pkgs.callPackage ./capture { };
  stlink-udev = pkgs.callPackage ./stlink-udev { };
  qxw = pkgs.callPackage ./qxw { };
} // append_pkgs
