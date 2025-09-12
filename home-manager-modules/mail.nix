# Email configuration per my preferences
{ osConfig, config, lib, pkgs, ... }:
with lib;
let
  # Configuration related
  cfg = config.kinnison.email;
  enabled = cfg.enable && (cfg.accounts != { });

  useHelix = config.kinnison.helix.enable;

  hx-mail = pkgs.writeShellApplication {
    name = "hx-mail";
    text = ''
      filename="$1"
      line=$(grep -n '^$' "$filename" | head -1 | cut -d: -f1)
      line=$((line + 1))
      exec hx "$filename:$line"
    '';
  };

  editor = if useHelix then "${hx-mail}/bin/hx-mail" else "vim +/^$ ++1";

  # Email account options
  emailAccount = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        readOnly = true;
        description =
          "The name for the account, eg. 'home' set to the attribute name";
      };
      primary = mkOption {
        type = types.bool;
        description = "Whether this address is primary";
        default = false;
      };
      realName = mkOption {
        type = types.str;
        description = "The 'real' name for the email account";
      };
      address = mkOption {
        type = types.str;
        description = "The email address for the account";
      };
      userName = mkOption {
        type = types.str;
        description = "The username to log into the imap/smtp server with";
      };
      mailServer = mkOption {
        type = types.str;
        description = "The hostname of the mail server";
      };

      displayFolders = mkOption {
        type = types.listOf types.str;
        default = [ "Inbox" ];
        example = ''[ "Inbox" ]'';
        description = "List of folders *in order* to display for this account";
      };

      watchFolders = mkOption {
        type = types.listOf types.str;
        default = [ "Inbox" ];
        example = ''[ "Inbox" ]'';
        description =
          "List of folders to watch via imapnotify for this account";
      };

      signature = mkOption {
        type = types.str;
        description = "Email signature for this account";
      };

      extraConfig = mkOption {
        type = types.attrs;
        description = "Any extra configuration for the account";
        default = { };
      };
    };
    config = { name = name; };
  };

  # Configuration file building, scripting, etc.
  folder-config = let
    accounts = attrValues cfg.accounts;
    primaryAccount = head (filter (a: a.primary) accounts ++ accounts);
    otherAccounts = filter (a: a != primaryAccount) accounts;

    accountConfig = account:
      let
        baseDir = "${cfg.maildirBase}/${account.name}";
        folders = account.displayFolders;
        folder-parts = folder: splitString "/" folder;
        folder-suffix = folder: last (folder-parts folder);
        folder-prefix = folder:
          concatStringsSep "" (map (f: "  ") (folder-parts folder));
        folder-name = folder: ''
          "${folder-prefix folder}${
            folder-suffix folder
          }" "${baseDir}/${folder}"
        '';
        folder-command = folder: "named-mailboxes ${folder-name folder}";
      in ''
        # Configuration for account '${account.name}'

        named-mailboxes "---${account.name}---" "${baseDir}/.null"
        ${concatMapStringsSep "" folder-command folders}
      '';
  in ''
    # First we clear all mailboxes
    unmailboxes *

    ${accountConfig primaryAccount}

    ${concatMapStringsSep "\n\n" accountConfig otherAccounts}
  '';
  mkGetMailPassScript = acc: ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.libsecret}/bin/secret-tool lookup \
      kind email account ${acc.address} user ${acc.userName} server ${acc.mailServer} | \
      ${pkgs.coreutils}/bin/head -1 | ${pkgs.coreutils}/bin/tr -d '\n'
  '';
  mkSetMailPassScript = acc: ''
    #!${pkgs.bash}/bin/bash

    echo "Setting password for account: ${acc.name}"
    echo "Email address: ${acc.address}"
    echo "This is for user: ${acc.userName}"
    echo "On server: ${acc.mailServer}"
    ${pkgs.libsecret}/bin/secret-tool store --label='Email settings for ${acc.name}' \
      kind email account ${acc.address} user ${acc.userName} server ${acc.mailServer}
  '';

  # Converted accounts
  ## Get Password scripts
  getPasswordFiles = concatMapAttrs (name: acc: {
    "neomutt/.${name}-email-password" = {
      executable = true;
      text = mkGetMailPassScript acc;
    };
  }) cfg.accounts;
  ## Set Password scripts
  setPasswordScripts = map (acc:
    pkgs.writeShellScriptBin "set-email-password-${acc.name}"
    (mkSetMailPassScript acc)) (attrValues cfg.accounts);

  emailAccounts = mapAttrs (name: acc: {
    primary = acc.primary;
    realName = acc.realName;
    address = acc.address;
    userName = acc.userName;
    passwordCommand =
      "${config.xdg.configHome}/neomutt/.${acc.name}-email-password";
    imap = {
      host = acc.mailServer;
      port = 993;
    };
    smtp = {
      host = acc.mailServer;
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
    mbsync = {
      create = "both";
      remove = "maildir";
      expunge = "both";
      enable = true;
    };
    msmtp = {
      enable = true;
      extraConfig.from = acc.address;
      extraConfig.domain = osConfig.networking.hostName;
    };
    neomutt = {
      enable = true;
      sendMailCommand = "msmtpq --read-recipients";
      extraConfig = folder-config;
    };
    signature = {
      showSignature = "append";
      text = acc.signature;
    };
    mu.enable = true;
    imapnotify = {
      enable = true;
      boxes = acc.watchFolders;
      onNotify = "${pkgs.systemd}/bin/systemctl --user start mbsync.service";
    };
    folders = { sent = "Inbox"; };
  }) cfg.accounts;

  extraMailConfigs = mapAttrs (name: acc: acc.extraConfig) cfg.accounts;

in {
  options.kinnison.email = {
    enable = mkEnableOption "Email Configuration";

    mainMuttConfig = mkOption {
      type = types.lines;
      description = "The main chunk of mutt configuration";
    };

    muttColours = mkOption {
      type = types.lines;
      description = "The colours configuration for mutt";
    };

    muttHeaders = mkOption {
      type = types.lines;
      description = "The settings for mutt headers";
    };

    maildirBase = mkOption {
      type = types.str;
      description = "The base maildir path";
      default = "${config.xdg.dataHome}/mail";
    };

    accounts = mkOption {
      type = types.attrsOf (types.submodule emailAccount);
      description = "The email accounts to be enabled";
      default = { };
    };
  };

  # options.accounts.email.accounts.display-folders = mkOption {
  #   type = types.listOf types.str;
  #   default = [ "Inbox" ];
  #   example = ''[ "Inbox" ]'';
  #   description = "List of folders *in order* to display for this account";
  # };

  config = mkIf enabled (mkMerge [
    {
      kinnison.email = {
        mainMuttConfig = ''
          set edit_headers = yes
          set fast_reply = yes
          set postpone = ask-no
          set read_inc = '100'
          set reverse_alias = yes
          set rfc2047_parameters = yes
          set charset = 'utf-8'
          set markers = no
          set menu_scroll = yes
          set write_inc = '100'
          set pgp_verify_command = '${pkgs.gnupg}/bin/gpg --status-fd=2 --verbose --batch --output - --verify-options show-uid-validity --verify %s %f'
          set beep_new = yes
          set collapse_unread = no
          set delete = yes
          set move = no
          set mime_forward = ask-yes
          set use_envelope_from = yes
          set quit = ask-no
          set suspend = no
          set mark_old = no
          set wait_key = no
          set strict_threads = yes
          auto_view 'text/html'
          alternative_order text/calendar text/enriched text/plain text/html text application/postscript image/*
          set mailcap_path = "${config.xdg.configHome}/neomutt/mailcap:$mailcap_path"
        '';
        muttColours = ''
          # Colouring snarfed from:
          #  https://raw.githubusercontent.com/catppuccin/neomutt/7a7f53246a91c70ffe7a973ee48b42dbc254acc6/neomuttrc

          color normal		  default default         # Text is "Text"
          color index		    color2 default ~U       # Unread Messages are Green
          color index		    color1 default ~F       # Flagged messages are Red
          color index		    color13 default ~T      # Tagged Messages are Red
          color index		    color1 default ~D       # Messages to delete are Red
          color attachment	color5 default          # Attachments are Pink
          color signature	  color8 default          # Signatures are Surface 2
          color search		  color4 default          # Highlighted results are Blue

          color indicator		default color8          # currently highlighted message Surface 2=Background Text=Foreground
          color error		    color1 default          # error messages are Red
          color status		  color15 default         # status line "Subtext 0"
          color tree        color15 default         # thread tree arrows Subtext 0
          color tilde       color15 default         # blank line padding Subtext 0

          color hdrdefault  color13 default         # default headers Pink
          color header		  color13 default "^From:"
          color header	 	  color13 default "^Subject:"

          color quoted		  color15 default         # Subtext 0
          color quoted1		  color7 default          # Subtext 1
          color quoted2		  color8 default          # Surface 2
          color quoted3		  color0 default          # Surface 1
          color quoted4		  color0 default
          color quoted5		  color0 default

          color body		color2 default		[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+               # email addresses Green
          color body	  color2 default		(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+        # URLs Green
          color body		color4 default		(^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$) # *bold* text Blue
          color body		color4 default		(^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)     # _underlined_ text Blue
          color body		color4 default		(^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)     # /italic/ text Blue

          color sidebar_flagged   color1 default    # Mailboxes with flagged mails are Red
          color sidebar_new       color10 default   # Mailboxes with new mail are Green

        '';
        muttHeaders = ''
          ignore *

          unignore from to cc subject date list-id
        '';

      };

      # The various packages we need enabled
      home.packages = with pkgs; [ neomutt ];

      systemd.user.sessionVariables = lib.mkMerge [
        (lib.mkIf (config.home.sessionVariables ? MSMTPQ_Q) {
          inherit (config.home.sessionVariables) MSMTPQ_Q;
        })
        (lib.mkIf (config.home.sessionVariables ? MSMTPQ_LOG) {
          inherit (config.home.sessionVariables) MSMTPQ_LOG;
        })
      ];

      # Now the various programs and services
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        mu.enable = true;
        neomutt = {
          enable = true;
          sidebar = {
            enable = true;
            shortPath = true;
            format = "%D%?F? [%F]?%* %?N?%N/?%?S?%S?";
            width = 30;
          };
          checkStatsInterval = 60;
          inherit editor;
          extraConfig = ''
            # General config
            ${cfg.mainMuttConfig}

            # Colours
            ${cfg.muttColours}

            # Headers
            ${cfg.muttHeaders}
          '';
          binds = [
            {
              map = [ "index" ];
              key = "<esc>,";
              action = "sidebar-prev";
            }
            {
              map = [ "index" ];
              key = "<esc>.";
              action = "sidebar-next";
            }
            {
              map = [ "index" ];
              key = "<esc><enter>";
              action = "sidebar-open";
            }
            {
              map = [ "index" ];
              key = "<esc><return>";
              action = "sidebar-open";
            }
            {
              map = [ "index" ];
              key = "<esc><space>";
              action = "sidebar-open";
            }
          ];
          macros = [
            {
              map = [ "index" ];
              key = "<esc>n";
              action = "<limit>~U<enter>";
            }
            {
              map = [ "index" ];
              key = "<esc>V";
              action = "<change-folder-readonly>${cfg.maildirBase}/mu<enter>";
            }
            {
              map = [ "index" ];
              key = "V";
              action =
                "<change-folder-readonly>${cfg.maildirBase}/mu<enter><shell-escape>mu find --format=links --linksdir=${cfg.maildirBase}/mu --clearlinks ";
            }
          ];
        };
      };
      accounts.email.maildirBasePath = cfg.maildirBase;
      services.mbsync = {
        preExec = "${config.xdg.dataHome}/mail/.presync";
        postExec = "${config.xdg.dataHome}/mail/.postsync";
        frequency = "*:0/3";
        enable = true;
      };
      services.imapnotify.enable = true;

      xdg.dataFile."mail/.postsync" = {
        executable = true;
        text = ''
          #!/bin/sh

          ${pkgs.mu}/bin/mu index
        '';
      };

      xdg.dataFile."mail/.presync" = {
        executable = true;
        text = let
          mbsyncAccounts = filter (a: a.mbsync.enable)
            (attrValues config.accounts.email.accounts);
        in ''
          #!/bin/sh

          for account in ${
            concatMapStringsSep " " (a: a.name) mbsyncAccounts
          }; do
            target="${cfg.maildirBase}/$account/.null"
            ${pkgs.coreutils}/bin/ln -sf /dev/null "$target"
            MAILPASS=$(${config.xdg.configHome}/neomutt/.''${account}-email-password)
            if test "x$MAILPASS" = "x"; then
              echo "Cannot continue, missing $account password"
              exit 1;
            fi
          done
        '';
      };
      xdg.configFile."neomutt/mailcap" = {
        executable = false;
        text = ''
          text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -dump -T text/html '%s'; copiousoutput; description=HTML Text; nametemplate=%s.html
          # Images using swayimg
          image/jpeg; ${pkgs.swayimg}/bin/swayimg '%s'; test=test "$WAYLAND_DISPLAY"
          image/png; ${pkgs.swayimg}/bin/swayimg '%s'; test=test "$WAYLAND_DISPLAY"
          # This relies on firefox on PATH
          application/pdf; firefox '%s'; test=test "$WAYLAND_DISPLAY"
        '';
      };
      # We use msmtpq to send email, which means if we save the mail offline we
      # can run this queue runner from time to time.
      systemd.user.services.msmtp-queue-runner = {
        Unit = { Description = "msmtp-queue runner"; };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.msmtp}/bin/msmtp-queue -r";
        };
      };

      systemd.user.timers.msmtp-queue-runner = {
        Unit = { Description = "msmtp-queue runner"; };
        Timer = {
          Unit = "msmtp-queue-runner.service";
          OnCalendar = "*:0/5";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
    }
    {
      xdg.configFile = getPasswordFiles;
      home.packages = setPasswordScripts;
      accounts.email.accounts = emailAccounts;
      systemd.user.services = builtins.listToAttrs (map (acc: {
        name = "imapnotify-${acc}";
        value = {
          Service.ExecStartPre = "${config.xdg.dataHome}/mail/.presync";
        };
      }) (attrNames cfg.accounts));
    }
    { accounts.email.accounts = extraMailConfigs; }
    (mkIf useHelix {
      programs.helix.languages = {
        language = [{
          name = "mail";
          file-types = [{ glob = "neomutt-*"; }];
          language-servers = [ "hanumail" ];
          rulers = [ 78 ];
        }];
        language-server.hanumail = {
          command = "${pkgs.kinnison.hanumail}/bin/hanumail";
        };
      };
    })
  ]);
}
