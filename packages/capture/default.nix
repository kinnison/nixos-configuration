{ pkgs, sway, jq, slurp, grim, rofi, ... }:
let swaymsg = "${sway}/bin/swaymsg";
in pkgs.writeShellScriptBin "capture" ''

  TMPDIR=$(mktemp -d)
  cleanup () { rm -rf "$TMPDIR"; }
  trap cleanup 0

  WINDOWS=$(${swaymsg} -t get_tree | ${jq}/bin/jq -r '.. | select(.pid? and .visible?) | {name} + .rect | "\(.x),\(.y) \(.width)x\(.height) \(.name)"')
  SELECTED=$(echo $WINDOWS | ${slurp}/bin/slurp -f '{"grim":"%x,%y %wx%h","label":"%l"}' -d)
  if test $? = 1; then
    exit 0
  fi
  GRIMPOS=$(echo $SELECTED | ${jq}/bin/jq -r '.grim')
  FNAME="$(echo $SELECTED | ${jq}/bin/jq -r '.label').png"

  ${grim}/bin/grim -g "$GRIMPOS" "''${TMPDIR}/grab.png"

  FILENAME=$(echo $FNAME | ${rofi}/bin/rofi -dmenu -p "Screenshot" -i -mesg "Enter the filename to save the screenshot")

  if test "x$FILENAME" != "x"; then
    mv "''${TMPDIR}/grab.png" "$FILENAME"
  fi

''
