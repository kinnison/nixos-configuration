{ lib, rustPlatform, fetchFromGitHub, nix-update-script, }:

rustPlatform.buildRustPackage rec {
  pname = "harper";
  version = "0.56.0+fix-1707";

  src = fetchFromGitHub {
    owner = "Automattic";
    repo = "harper";
    rev = "master";
    hash = "sha256-i+YIPWQAiiairz6jJL7BY4vTbURdI8IG4cRhmjWRTZw=";
  };

  buildAndTestSubdir = "harper-ls";

  cargoHash = "sha256-Ir7EDjN1+cFOc0Sm59LPmChbDwCuF6f17vg+5vwjEoo=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Grammar Checker for Developers";
    homepage = "https://github.com/Automattic/harper";
    changelog = "https://github.com/Automattic/harper/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pbsds sumnerevans ];
    mainProgram = "harper-ls";
  };
}
