# Wayland based configuration
{ osConfig, config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption mkForce;
  guicfg = osConfig.kinnison.gui;
  waybar-battery-modules = [ ];
  waybar-battery-blocks = { };
  rofi-bin = "${config.programs.rofi.package}/bin/rofi";
  rofi-lock =
    pkgs.kinnison.rofi-lock.override { rofi = config.programs.rofi.package; };
in {
  options.kinnison.batteries = mkOption {
    description = "Batteries, if any";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = mkIf guicfg.wayland.enable {
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
      systemd.enable = true;
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
        };
      };
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
          command = "lock";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -fF";
        }
        {
          timeout = 300;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

    programs.foot = {
      enable = true;
      catppuccin.enable = false;
      settings = {
        main = {
          term = "xterm-256color";
          font = mkForce "InconsolataNerdFont:size=20";
          dpi-aware = mkForce "yes";
        };
        mouse = { hide-when-typing = "yes"; };
      };
    };

    programs.swayr = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
      settings = {
        menu = {
          executable = "${config.programs.rofi.package}/bin/rofi";
          args = [
            "-dmenu"
            "-markup"
            "-show-icons"
            "-no-case-sensitive"
            "-no-drun-use-desktop-cache"
            "-l"
            "20"
            "-p"
            "{prompt}"
          ];
        };
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
          modules-right = [ "memory" "cpu" "network" ] ++ waybar-battery-modules
            ++ [ "temperature" "clock" "pulseaudio" "tray" "idle_inhibitor" ];

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
          "sway/scratchpad" = {
            "format" = "{icon} {count}";
            "show-empty" = false;
            "format-icons" = [ "" "<U+F2D2>" ];
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

        } // waybar-battery-blocks;
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
  };
}
