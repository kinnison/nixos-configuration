{ stdenv, group ? "plugdev", ... }:
stdenv.mkDerivation {
  name = "stlink-udev";
  version = "1.0.3-2";
  src = ./.;
  installPhase = ''
    mkdir -p $out/etc/udev/rules.d
    for F in *.rules; do
      sed -e 's/@@GROUP@@/${group}/g' < $F > $out/etc/udev/rules.d/$F
    done
  '';
}
