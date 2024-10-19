# Systems (and thus installers) for all relevant systems
{ systems, pkgs, ... }:
let
  allSystemNames = builtins.attrNames systems;
  systemNames = builtins.filter (n: n != "installer") allSystemNames;
  topLevel = system: systems.${system}.config.system.build.toplevel;
  flake = ./../..;
  installer = system:
    pkgs.writeShellScriptBin "disko-install-${system}" ''
      disko-install -f ${flake}#${system} "$@"
    '';
  installers = builtins.map (installer) systemNames;
  toplevels = builtins.map (system: {
    name = "toplevels/${system}";
    value = { source = topLevel system; };
  }) systemNames;
in {
  environment.systemPackages = installers;
  environment.etc = builtins.listToAttrs toplevels;
}
