# Wayland based configuration
{ osConfig, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption;
  guicfg = osConfig.kinnison.gui;
  waybar-battery-modules = [ ];
  waybar-battery-blocks = { };
in {
  options.kinnison.batteries = mkOption {
    description = "Batteries, if any";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = mkIf guicfg.wayland.enable {
    programs.swaylock = {
      enable = true;
      catppuccin.enable = true;
    };
    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      systemd.enable = true;
      config.bars = [ ];
      config.input."type:keyboard" = {
        xkb_layout = "gb";
        xkb_options = "compose:caps";
      };
      config.window = {
        titlebar = false;
        border = 1;
      };
      config.gaps = {
        smartBorders = "on";
        smartGaps = true;
      };
    };

    programs.foot = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          font = "InconsolataNerdFont:size=20";
          dpi-aware = "yes";
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
  };
}
