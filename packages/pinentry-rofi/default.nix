{ lib, stdenv, fetchFromGitHub, makeWrapper, bash, rofi, coreutils, gnused, gawk
}:
stdenv.mkDerivation {
  pname = "pinentry-rofi";
  version = "main";
  src = fetchFromGitHub {
    owner = "zamlz";
    repo = "pinentry-rofi";
    rev = "main";
    hash = "sha256-R4SFHrTHmE8wFza6tvEBMbcVE7/0S9mTFPNi8QOp0Zw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    # Nothing to do
  '';

  installPhase = ''
    mkdir -p $out/bin
    sed -E -e's@^#!.*$@#!${bash}/bin/bash@' -e's@^ROFI="[^ ]+@ROFI="${rofi}/bin/rofi@' < src/pinentry-rofi.sh > $out/bin/pinentry-rofi
    chmod +x $out/bin/pinentry-rofi
    wrapProgram $out/bin/pinentry-rofi --prefix PATH : ${
      lib.makeBinPath [ coreutils gnused gawk ]
    }
  '';

  meta.mainProgram = "pinentry-rofi";
}
