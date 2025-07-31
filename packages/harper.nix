{ lib, rustPlatform, fetchFromGitHub, nix-update-script, }:

rustPlatform.buildRustPackage rec {
  pname = "harper";
  version = "0.53.0+fix-1064";

  src = fetchFromGitHub {
    owner = "kinnison";
    repo = "harper";
    rev = "fix-1064";
    hash = "sha256-iLCGqcCmFTGHj2K4eKlKb3dnoSTkd2qQUyEVSWt4E7I=";
  };

  buildAndTestSubdir = "harper-ls";

  cargoHash = "sha256-etNmmPStjrsl4iS6kJxyzopiTqSCwX6K4dzT3EVxScE=";

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
