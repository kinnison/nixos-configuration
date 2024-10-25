# Git configuration in home-manager
{ config, osConfig, lib, ... }:
with lib;
let
  cfg = config.kinnison.git;
  usercfg = osConfig.kinnison.user;
in {
  options.kinnison.git = {
    enable = mkEnableOption "Git configuration";
    email = mkOption {
      description = "Default Email address";
      type = lib.types.str;
    };
    signKey = mkOption {
      description =
        "Key to sign with by default (needs kinnison.gpg.enable = true)";
      type = lib.types.str;
      default = "0x3CCEBABE206C3B69";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.gh = {
        enable = true;
        settings = { git_protocol = "ssh"; };
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
        userName = usercfg.realName;
        userEmail = cfg.email;
        extraConfig = {
          branch.autoSetupRebase = "always";
          checkout.defaultRemote = "origin";
          init = { defaultBranch = "main"; };

          pull.rebase = true;
          pull.ff = "only";
          push.default = "current";

          format.signoff = true;

          rebase.autosquash = true;

          url."ssh://git@github.com/".pushInsteadOf =
            [ "git://github.com/" "https://github.com/" ];
          url."ssh://git@gitlab.com/".pushInsteadOf =
            [ "git://gitlab.com/" "https://gitlab.com/" ];
          url."ssh://nsgit@git.netsurf-browser.org/".pushInsteadOf = [
            "git://git.netsurf-browser.org/"
            "https://git.netsurf-browser.org/"
          ];
          alias = { st = "status"; };
        };
      };
    })
    (mkIf (cfg.enable && config.kinnison.gnupg.enable) {
      programs.git.signing = {
        key = cfg.signKey;
        signByDefault = true;
      };
    })
  ];
}
