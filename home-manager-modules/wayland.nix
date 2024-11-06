# Wayland based configuration
{ osConfig, config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption mkForce;
  guicfg = osConfig.kinnison.gui;
  # TODO
  batcfg = config.kinnison.batteries;
  waybar-batteries = if batcfg == [ ] then {
    modules = [ ];
    blocks = { };
  } else
    let
      first-battery = builtins.head batcfg;
      is-first = bat: bat == first-battery;
      modname = bat: if is-first bat then "battery" else "battery#${bat}";
      modules = map modname batcfg;
      blocks = builtins.listToAttrs (map (bat: {
        name = modname bat;
        value = {
          inherit bat;
          states = {
            good = 80;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰃨";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
      }) batcfg);
    in {
      inherit modules;
      inherit blocks;
    };
  rofi-bin = "${config.programs.rofi.package}/bin/rofi";
  rofi-lock =
    pkgs.kinnison.rofi-lock.override { rofi = config.programs.rofi.package; };
  dmenu = pkgs.writeShellScriptBin "dmenu" ''
    exec ${rofi-bin} -dmenu "$@"
  '';
  capture =
    pkgs.kinnison.capture.override { rofi = config.programs.rofi.package; };
  new-workspace-pkg = pkgs.writeShellScriptBin "new-workspace" ''
    NEW_WS=$(comm -13 \
      <(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.orientation? and .output?) | .num' | sort -n) \
      <(seq 1 9) \
      | head -1)
      
    if test "x$NEW_WS" != "x"; then
      swaymsg workspace $NEW_WS
    fi
  '';
  new-workspace = "${new-workspace-pkg}/bin/new-workspace";
in {
  options.kinnison.batteries = mkOption {
    description = "Batteries, if any";
    type = lib.types.listOf lib.types.str;
    default = osConfig.kinnison.batteries;
  };

  config = mkIf guicfg.wayland.enable {
    home.packages = [ dmenu capture pkgs.swayimg ];
    programs.swaylock = {
      enable = true;
      catppuccin.enable = false;
      settings = {
        font-size = 24;
        indicator-radius = 250;
        show-failed-attempts = true;
      };
    };
    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
      config = {
        bars = [ ];
        input."type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "compose:caps";
        };
        window = {
          titlebar = false;
          border = 1;
        };
        gaps = {
          smartBorders = "on";
          smartGaps = true;
        };
        menu = "rofi -show drun";
        focus = { wrapping = "workspace"; };
        # The recommendation is to not override all the bindings,
        # but we're going to do so because we really want to
        keybindings = let conf = config.wayland.windowManager.sway.config;
        in {
          "Mod4+x" = "exec ${pkgs.foot}/bin/foot";
          "Mod4+e" = "exec ${rofi-bin} -modi emoji -show emoji";
          "Mod1+f2" = "exec ${rofi-bin} -show run";
          "Mod1+f3" = "exec ${conf.menu}";
          "Control+Mod1+Left" = "workspace prev_on_output";
          "Control+Mod1+Right" = "workspace next_on_output";
          "Mod4+Tab" = "focus next";
          "Mod4+Shift+Tab" = "focus prev";
          # Move window one workspace prev / next
          "Control+Shift+Mod1+Left" =
            "move container to workspace prev_on_output;workspace prev_on_output";
          "Control+Shift+Mod1+Right" =
            "move container to workspace prev_on_output;workspace prev_on_output";
          # Move window one output prev/next
          # "Control+Shift+Mod1+Up" = "";
          # "Control+Shift+Mod1+Down" = "";
          # Switch focus one output prev/next
          # "Control+Mod1+Up" = "";
          # "Control+Mod1+Down" = "";
          "Mod1+f4" = "kill";
          "Mod1+f11" = "fullscreen toggle";
          "Mod4+Shift+r" = "reload";
          "Control+Mod1+l" = "exec ${pkgs.swaylock}/bin/swaylock -fF";
          "Control+Mod4+Mod1+s" = "exec ${rofi-lock}/bin/rofi-lock";

          # Layout switching
          "Mod4+Space" = "layout toggle splith splitv tabbed";

          # These aren't great because they moose up mod-tab
          # "Mod4+Up" = "move up";
          # "Mod4+Down" = "move down";
          # "Mod4+Left" = "move left";
          # "Mod4+Right" = "move right";

          # New bindings I might get used to
          "Mod4+k" = "kill";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+l" = "exec ${pkgs.swaylock}/bin/swaylock -fF";
          "Mod4+q" = "exec ${rofi-lock}/bin/rofi-lock";
          "Mod4+t" = "exec ${new-workspace}";
          "Mod4+n" = "exec ${new-workspace}";
          "Print" = "exec capture";
        };

      };
      extraConfig = ''
        bindswitch lid:on exec systemctl suspend
        exec sleep 1 && swaymsg output "*" background "#000000" solid_color
      '';
    };

    services.swayidle = {
      enable = true;
      systemdTarget = "sway-session.target";
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

    programs.foot = {
      enable = true;
      server.enable = true;
      catppuccin.enable = false;
      settings = {
        main = {
          term = "xterm-256color";
          font = mkForce "InconsolataNerdFont:size=16";
          dpi-aware = mkForce "yes";
        };
        mouse = { hide-when-typing = "yes"; };
      };
    };

    programs.waybar = {
      enable = true;
      catppuccin.enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
      style = ''
        * {
          color: @text;
        }

        window#waybar {
          background-color: shade(@base, 0.9);
          border: 2px solid alpha(@crust, 0.3);
        }
      '';
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          spacing = 4;
          modules-left = [ "sway/workspaces" "sway/mode" "sway/scratchpad" ];
          modules-center = [ "sway/window" ];
          modules-right = [ "memory" "cpu" "network" ]
            ++ waybar-batteries.modules
            ++ [ "temperature" "clock" "pulseaudio" "tray" "idle_inhibitor" ];

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
          "sway/scratchpad" = {
            "format" = "{icon} {count}";
            "show-empty" = false;
            "format-icons" = [ "" "" ];
            "tooltip" = true;
            "tooltip-format" = "{app}: {title}";
          };
          idle_inhibitor = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          tray.spacing = 10;
          clock = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%Y-%m-%d}";
          };
          memory = { "format" = "{}% "; };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" ];
          };
          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

        } // waybar-batteries.blocks;
      };
    };
    services.dunst = {
      enable = true;
      catppuccin.enable = true;
    };
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland.override {
        plugins = [
          (pkgs.rofi-emoji.override {
            rofi-unwrapped = pkgs.rofi-wayland-unwrapped;
          })
        ];
      };
      extraConfig = {
        modi = "drun,emoji,run";
        kb-primary-paste = "Control+V,Shift+Insert";
        kb-secondary-paste = "Control+v,Insert";
        icon-theme = "Papirus";
        show-icons = true;
      };
    };
    programs.wpaperd = {
      enable = true;
      settings = {
        default = {
          mode = "stretch";
          sorting = "random";
          transition-time = "500";
          duration = "5m";
        };
        any = { path = lib.mkForce "${pkgs.kinnison.cats}"; };
      };
    };
    systemd.user.services.wpaperd = {
      Unit = {
        Description = "Wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${config.programs.wpaperd.package}/bin/wpaperd";
      };
      Install = { WantedBy = [ "sway-session.target" ]; };
    };
  };
}
