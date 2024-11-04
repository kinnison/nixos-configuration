# Rofi Lock script package
{ pkgs, lib, rofi, swaylock, sway, ... }:
let
  actions = [
    {
      text = "Lock Screen";
      action = "${swaylock}/bin/swaylock -fF";
    }
    {
      text = "Log Out";
      action = "${sway}/bin/swaymsg exit";
    }
    {
      text = "Suspend Computer";
      action = "systemctl suspend";
    }
    {
      text = "Reboot Computer";
      action = "reboot";
    }
    {
      text = "Shutdown Computer";
      action = "poweroff";
    }
  ];

  action-texts = builtins.map (e: e.text) actions;

  action-str = builtins.concatStringsSep "\\n" action-texts;
  action-select = lib.concatImapStringsSep "\n" (i: e: ''
    "x${builtins.toString i}")
      ${e.action}
      ;;
  '') actions;
in pkgs.writeShellScriptBin "rofi-lock" ''

  ACTION=$(echo -e "${action-str}" | ${rofi}/bin/rofi -dmenu -p "Action" -no-custom -i -mesg "Select what to do next" -window-title "Lock/Shutdown" -format d)

  case "x$ACTION" in
    ${action-select}
    *)
      ;;
  esac
''
