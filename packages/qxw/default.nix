{ pkgs, stdenv, fetchurl, scowl, ... }:
stdenv.mkDerivation {
  pname = "qxw";
  version = "20200708";
  src = fetchurl {
    url = "https://www.quinapalus.com/qxw-20200708.tar.gz";
    hash = "sha256-7Wxu/7gVeJ7D9yFHOMkFVw5YAw5bjltJP+yMcBSNI+o=";
  };

  patches = [ ./scowl-dict.patch ];
  patchFlags = "-p2";
  postPatch = ''
    substituteInPlace dicts.c --subst-var-by SCOWL_DICT ${scowl}/share/dict/wbritish_s.95
  '';
  nativeBuildInputs = with pkgs; [ gnumake pkg-config gtk2 pcre scowl ];

  makeFlags = "DESTDIR=$(out)/";
  postInstall = ''
    mkdir ''${out}/bin
    mv ''${out}/usr/games/qxw ''${out}/bin
    rm -rf ''${out}/usr
  '';
}
