# Systems (and thus installers) for all relevant systems
{ systems, pkgs, flakeInputs, lib, ... }:
let
  allSystemNames = builtins.attrNames systems;
  systemNames = builtins.filter (n: n != "installer") allSystemNames;
  topLevel = system: systems.${system}.config.system.build.toplevel;
  bootLoader = system: systems.${system}.config.system.build.installBootLoader;
  flake = ./../..;
  installer = system:
    pkgs.writeShellScriptBin "disko-install-${system}" ''
      disko-install -f ${flake}#${system} --system-config '{"kinnison":{"installer-image":true}}' "$@"
    '';
  bootloader-installer = system: {
    name = "bootloader-installers/${system}";
    value = { source = bootLoader system; };
  };
  installers = builtins.map (installer)
    (builtins.filter (name: !lib.hasSuffix "-installable" name) systemNames);
  bootloader-installers = builtins.map (bootloader-installer) systemNames;
  toplevels = builtins.map (system: {
    name = "toplevels/${system}";
    value = { source = topLevel system; };
  }) systemNames;
  flakeMap = base: fin:
    let
      flakeIsToplevel = fname: fin.${fname} ? toplevelMarker;
      fnames = builtins.filter (n: n != "self" && !(flakeIsToplevel n))
        (builtins.attrNames fin);
      flakes = builtins.map (fname: {
        name = "${base}${fname}";
        value = { source = fin.${fname}; };
      }) fnames;
      submaps = builtins.map (fname:
        let
          subbase = "${base}${fname}_";
          f = fin.${fname};
          finputs = if f ? inputs then f.inputs else { };
        in flakeMap subbase finputs) fnames;
      allsubs = builtins.concatLists submaps;
    in flakes ++ allsubs;
  flakes = flakeMap "flakes/" flakeInputs;
in {
  environment.systemPackages = installers;
  environment.etc =
    builtins.listToAttrs (toplevels ++ flakes ++ bootloader-installers);
}
