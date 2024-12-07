# Systems (and thus installers) for all relevant systems
{ systems, pkgs, flakeInputs, lib, ... }:
let
  allSystemNames = builtins.attrNames systems;
  systemNames = builtins.filter (n: n != "installer") allSystemNames;
  deps-for-closure-for = system: [
    systems.${system}.config.system.build.toplevel
    systems.${system}.config.system.build.diskoScript
    systems.${system}.config.system.build.diskoScript.drvPath
    systems.${system}.pkgs.stdenv.drvPath
    # Perl packages needed for systemd-boot setup
    systems.${system}.pkgs.perlPackages.ConfigIniFiles
    systems.${system}.pkgs.perlPackages.FileSlurp
    # And the packages closure itself
    (systems.${system}.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  ];
  closure-for-systems = let
    alldeps = builtins.concatMap deps-for-closure-for systemNames;
    mydeps =
      builtins.map (i: i.outPath) (builtins.attrValues flakeInputs.self.inputs);
    allFlakes = let
      recFlake = seen: fname: f:
        let
          found = builtins.elem fname seen;
          seen' = seen ++ [ fname ];
          done = let inputs = if f ? inputs then f.inputs else { };
          in [ f.outPath ] ++ (recFlakes seen' inputs);
        in if found then [ ] else done;
      recFlakes = seen: fis:
        let allFlakes = lib.mapAttrsToList (recFlake seen) fis;
        in builtins.concatLists allFlakes;
    in lib.unique (recFlakes [ ] flakeInputs);
  in pkgs.closureInfo { rootPaths = alldeps ++ mydeps ++ allFlakes; };
  flake = flakeInputs.self;
  installer = system:
    pkgs.writeShellScriptBin "disko-install-${system}" ''
      disko-install -f ${flake}#${system}-installable --write-efi-boot-entries "$@"
    '';
  installers = builtins.map (installer)
    (builtins.filter (name: !lib.hasSuffix "-installable" name) systemNames);
in {
  environment.systemPackages = installers;
  environment.etc."install-closure".source =
    "${closure-for-systems}/store-paths";
}
