{ config, lib, hm-modules, ... }:
let
  inherit (lib) mkOption mkIf mkForce;
  cfg = config.kinnison.user;
  imperm = config.kinnison.impermanence.enable;
in {
  options.kinnison.user = {
    name = mkOption {
      type = lib.types.str;
      description = "Username to set up on the host";
    };
    groups = mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = "Groups to add this user to";
    };
    extra = mkOption {
      description = "Extra stuff to merge into the users attrset";
      default = { };
    };
    home = mkOption {
      description = "The user's home configuration";
      type = lib.types.path;
    };
    realName = mkOption {
      description = "The user's real name";
      type = lib.types.str;
      default = cfg.name;
    };
    autoLogin = mkOption {
      description =
        "Whether or not to try and automatically log in to graphical envs";
      type = lib.types.bool;
      default = true;
    };
    extraHomeModules = mkOption {
      description = "Extra home modules";
      default = [ ];
    };
  };

  config = {
    users.mutableUsers = mkIf imperm (mkForce false);
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = cfg.groups ++ [ "wheel" ];
      description = cfg.realName;
    } // cfg.extra;
    home-manager.users.${cfg.name} = {
      imports = hm-modules ++ [ cfg.home ] ++ cfg.extraHomeModules;
    };
    nix.settings.trusted-users = [ cfg.name ];
  };
}
