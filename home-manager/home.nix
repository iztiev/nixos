{ config, pkgs, inputs, ... }:
{
  home.username = "iztiev";
  home.homeDirectory = "/home/iztiev";

  # ── Environment Variables ──
  home.sessionVariables = {
    # EDITOR = "nano";
    # VISUAL = "code";
    # Fix cursor size in XWayland apps (PyCharm, WebStorm, etc.)
    XCURSOR_SIZE = "24";  # Standard cursor size (24 or 32 typical)
    # Disable SSH agent to prevent key caching
    SSH_AUTH_SOCK = "";
  };

  # ── Directory Structure ──
  # Ensure Projects directory structure exists
  home.file."Projects/github/.keep".text = "";
  home.file."Projects/local/.keep".text = "";

  # ── SSH Public Keys ──
  # Note: All SSH public keys use sops secrets for email addresses
  # They are created via activation scripts below

  # ── User Packages ──
  home.packages = with pkgs; [
    # Browsers
    chromium

    # Development
    vscode
    claude-code
    jetbrains.pycharm
    jetbrains.webstorm

    # Utilities
    htop
    ripgrep
    fd
    unzip
  ];

  # ── Firefox with Declarative Extensions ──
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";

      Preferences = {
        # Privacy settings
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.pinned" = "";
        "browser.topsites.contile.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
    profiles.default = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
#        styl-us
      ];
      settings = {
        "browser.contentblocking.category" = "strict";
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;

        # Zoom settings
        "layout.css.devPixelsPerPx" = "1.0";
        "browser.zoom.siteSpecific" = true;  # Remember per-site zoom levels
        "browser.zoom.full" = true;          # Full page zoom (not text-only)
        "zoom.defaultPercent" = 150;
        "zoom.default" = 1.5;

        # Disable password saving and autofills
        "signon.rememberSignons" = false;    # Disable password manager
        "signon.autofillForms" = false;      # Disable autofill for login forms
        "browser.formfill.enable" = false;   # Disable form autofill
        "browser.aboutConfig.showWarning" = false;
        "browser.compactmode.show" = true;
      };
    };
  };

  # ── Git ──
  programs.git = {
    enable = true;
    userName = "Timur Izmagambetov";
    # user.email is set via sops template at ~/.config/git/config-email
    includes = [
      { path = "~/.config/git/config-email"; }
    ];
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── SSH ──
  # Directly manage SSH config file to ensure it's always created
  home.file.".ssh/config" = {
    force = true;
    text = ''
      Host github.com
        IdentityFile ~/.ssh/id_github
      Host gitlab.finq.kz
        IdentityFile ~/.ssh/id_github
      Host llm.sx
        IdentityFile ~/.ssh/id_dilcher
      Host 35.164.116.189
        IdentityFile ~/.ssh/id_dilcher
      Host 49.12.110.230
        IdentityFile ~/.ssh/id_dilcher
      Host 37.27.241.163
        IdentityFile ~/.ssh/id_dilcher
      Host *.backend.sx
        IdentityFile ~/.ssh/id_dilcher
      Host iztiev.dev
        IdentityFile ~/.ssh/id_hetzner
      Host *.iztiev.dev
        IdentityFile ~/.ssh/id_hetzner
      Host *.embeddings.sx
        IdentityFile ~/.ssh/id_dilcher
      Host *.liquid.mx
        IdentityFile ~/.ssh/id_dilcher
      Host *.devel.pm
        IdentityFile ~/.ssh/id_dilcher
      Host 138.201.206.85
        IdentityFile ~/.ssh/id_dilcher
      Host 195.201.164.162
        IdentityFile ~/.ssh/id_dilcher
      Host 37.27.141.78
        IdentityFile ~/.ssh/id_dilcher
      Host *.liquid.pm
        IdentityFile ~/.ssh/id_dilcher
      Host zt.moon.backend.sx
        IdentityFile ~/.ssh/id_dilcher
      Host 10.98.81.94
        IdentityFile ~/.ssh/id_dilcher
      Host 10.98.81.14
        IdentityFile ~/.ssh/id_dilcher
      Host *
        ServerAliveInterval 100
    '';
  };

  # ── Shell ──
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      rebuild-home = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      update = "nix flake update --flake ~/nixos";
      cleanup = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && nix-env --delete-generations +3 && sudo nix-collect-garbage -d";
    };
  };

  # ── Disable SSH Agent ──
  # Prevents gcr-ssh-agent from starting and caching SSH keys
  # You will be prompted for your passphrase on every SSH use
  systemd.user.services.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
  };
  systemd.user.sockets.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
  };

  # ── Desktop Entries for JetBrains IDEs ──
  # Fix taskbar icons by creating custom desktop entries
  xdg.desktopEntries = {
    pycharm = {
      name = "PyCharm";
      genericName = "Python IDE";
      comment = "Python IDE from JetBrains";
      exec = "pycharm %f";
      icon = "pycharm";
      terminal = false;
      categories = [ "Development" "IDE" ];
      type = "Application";
      startupNotify = true;
      settings = {
        StartupWMClass = "jetbrains-pycharm";
      };
    };

    webstorm = {
      name = "WebStorm";
      genericName = "JavaScript IDE";
      comment = "JavaScript IDE from JetBrains";
      exec = "webstorm %f";
      icon = "webstorm";
      terminal = false;
      categories = [ "Development" "IDE" ];
      type = "Application";
      startupNotify = true;
      settings = {
        StartupWMClass = "jetbrains-webstorm";
      };
    };
  };

  # ── KDE Plasma Configuration ──
  programs.plasma = {
    enable = true;

    # Panel configuration with pinned applications
    panels = [
      {
        location = "bottom";
        height = 66;  # 50% larger than default (44px * 1.5 = 66px)
        widgets = [
          "org.kde.plasma.kickoff"  # Application launcher
          {
            name = "org.kde.plasma.icontasks";  # Task Manager
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:firefox.desktop"
                  "applications:chromium-browser.desktop"
                  "applications:pycharm.desktop"
                  "applications:webstorm.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # Configure scaling through config files
    # Adjust values as needed: 1 = 100%, 1.25 = 125%, 1.5 = 150%, 2 = 200%
    configFile = {
      # Global KDE settings
      kdeglobals = {
        KScreen = {
          ScaleFactor = 1;
          ScreenScaleFactors = "1";
        };
      };

      # Font DPI settings (96 = 100%, 120 = 125%, 144 = 150%, 192 = 200%)
      kcmfonts = {
        General = {
          forceFontDPI = 96;
        };
      };

      # KWin Wayland settings
      kwinrc = {
        Xwayland = {
          Scale = 1;
        };
      };

      # Session Management - start with empty session
      ksmserverrc = {
        General = {
          loginMode = "emptySession";
          confirmLogout = false;  # Don't show confirmation popup when logging out
        };
      };
    };
  };

  # Declaratively manage per-monitor display configuration
  home.file.".config/kwinoutputconfig.json" = {
    force = true;  # Overwrite the existing file
    text = builtins.toJSON [
    {
      name = "outputs";
      data = [
        {
          connectorName = "DP-2";
          edidHash = "4348573bad2bca55a2420184dc7df7ec";
          edidIdentifier = "SAM 30291 810899790 37 2024 0";
          scale = 1;  # 100% scaling
          mode = {
            width = 3840;
            height = 2160;
            refreshRate = 59997;
          };
          overscan = 0;
          rgbRange = "Automatic";
          vrrPolicy = "Never";
          transform = "Normal";
          autoRotation = "InTabletMode";
          brightness = 1;
          sdrBrightness = 351;
          sdrGamutWideness = 0;
          colorProfileSource = "sRGB";
          highDynamicRange = false;
          wideColorGamut = false;
          iccProfilePath = "";
          maxBitsPerColor = 0;
          allowDdcCi = true;
          detectedDdcCi = false;
          allowSdrSoftwareBrightness = true;
          automaticBrightness = false;
          colorPowerTradeoff = "PreferEfficiency";
          edrPolicy = "always";
          sharpness = 0;
          autoBrightnessCurve = [ 0 0 0 0 0 0 ];
          uuid = "85438a87-f6e8-46be-aec9-7cfddf786259";
        }
        {
          connectorName = "DP-3";
          edidHash = "fc42c9d25203ce3902c0d2a73096f126";
          edidIdentifier = "SAM 30291 810899790 37 2024 0";
          scale = 1;  # 100% scaling
          mode = {
            width = 3840;
            height = 2160;
            refreshRate = 59997;
          };
          overscan = 0;
          rgbRange = "Automatic";
          vrrPolicy = "Never";
          transform = "Normal";
          autoRotation = "InTabletMode";
          brightness = 1;
          sdrBrightness = 351;
          sdrGamutWideness = 0;
          colorProfileSource = "sRGB";
          highDynamicRange = false;
          wideColorGamut = false;
          iccProfilePath = "";
          maxBitsPerColor = 0;
          allowDdcCi = true;
          detectedDdcCi = false;
          allowSdrSoftwareBrightness = true;
          automaticBrightness = false;
          colorPowerTradeoff = "PreferEfficiency";
          edrPolicy = "always";
          sharpness = 0;
          autoBrightnessCurve = [ 0 0 0 0 0 0 ];
          uuid = "a62434a8-3d89-45fb-80ad-0c96a8ac9255";
        }
      ];
    }
    {
      name = "setups";
      data = [
        {
          lidClosed = false;
          outputs = [
            {
              enabled = true;
              outputIndex = 0;
              position = {
                x = 0;
                y = 0;
              };
              priority = 2;
              replicationSource = "";
            }
            {
              enabled = true;
              outputIndex = 1;
              position = {
                x = 3840;
                y = 0;
              };
              priority = 1;
              replicationSource = "";
            }
          ];
        }
      ];
    }
  ];
  };

  # ── COSMIC Desktop Configuration ──
  # COSMIC uses RON (Rusty Object Notation) for configuration files
  # Configuration translated from ~/.config/cosmic dotfiles
  # All files use force = true to manage them declaratively
  xdg.configFile = {
    # ── Setup & Initial Configuration ──
    "cosmic/com.system76.CosmicSettings/v1/setup_complete" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = { force = true; text = "{}"; };

    # ── Time Applet ──
    "cosmic/com.system76.CosmicAppletTime/v1/first_day_of_week" = { force = true; text = "0"; };  # Sunday
    "cosmic/com.system76.CosmicAppletTime/v1/military_time" = { force = true; text = "true"; };   # 24-hour format

    # ── Background ──
    "cosmic/com.system76.CosmicBackground/v1/same-on-all" = { force = true; text = "true"; };

    # ── Compositor ──
    "cosmic/com.system76.CosmicComp/v1/autotile_behavior" = { force = true; text = "PerWorkspace"; };

    "cosmic/com.system76.CosmicComp/v1/xkb_config" = {
      force = true;
      text = ''
        (
            rules: "",
            model: "pc104",
            layout: "us,ru",
            variant: ",",
            options: Some("terminate:ctrl_alt_bksp"),
            repeat_delay: 600,
            repeat_rate: 25,
        )
      '';
    };

    # ── Idle/Power Management ──
    "cosmic/com.system76.CosmicIdle/v1/screen_off_time" = { force = true; text = "None"; };
    "cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time" = { force = true; text = "None"; };

    # ── Dock Configuration ──
    "cosmic/com.system76.CosmicPanel.Dock/v1/anchor" = { force = true; text = "Bottom"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/anchor_gap" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/size" = { force = true; text = "L"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/size_center" = { force = true; text = "L"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/size_wings" = { force = true; text = "L"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/opacity" = { force = true; text = "1.0"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/background" = { force = true; text = "ThemeDefault"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/spacing" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/expand_to_edges" = { force = true; text = "false"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/exclusive_zone" = { force = true; text = "false"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/border_radius" = { force = true; text = "12"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/layer" = { force = true; text = "Top"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/keyboard_interactivity" = { force = true; text = "None"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/margin" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/padding" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/padding_overlap" = { force = true; text = "false"; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/name" = { force = true; text = ''"Dock"''; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/output" = { force = true; text = ''"all"''; };
    "cosmic/com.system76.CosmicPanel.Dock/v1/autohover_delay_ms" = { force = true; text = "200"; };

    "cosmic/com.system76.CosmicPanel.Dock/v1/autohide" = {
      force = true;
      text = ''
        Some((
            wait_time: 1000,
            transition_time: 200,
            handle_size: 4,
            unhide_delay: 200,
        ))
      '';
    };

    "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_center" = {
      force = true;
      text = ''
        Some([
            "com.system76.CosmicPanelLauncherButton",
            "com.system76.CosmicPanelWorkspacesButton",
            "com.system76.CosmicPanelAppButton",
            "com.system76.CosmicAppList",
            "com.system76.CosmicAppletMinimize",
        ])
      '';
    };

    "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_wings" = { force = true; text = "None"; };

    # Dock favorites
    "cosmic/com.system76.CosmicPanel.Dock/v1/favorites" = {
      force = true;
      text = ''
        [
          "firefox.desktop",
          "code.desktop",
          "org.gnome.Nautilus.desktop",
          "org.gnome.Console.desktop",
          "com.slack.Slack.desktop",
          "org.telegram.desktop.desktop",
          "pycharm.desktop",
          "webstorm.desktop",
        ]
      '';
    };

    # ── Panel Configuration ──
    "cosmic/com.system76.CosmicPanel.Panel/v1/anchor" = { force = true; text = "Bottom"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/anchor_gap" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/size" = { force = true; text = "M"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/size_center" = { force = true; text = "M"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/size_wings" = { force = true; text = "M"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/opacity" = { force = true; text = "1.0"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/background" = { force = true; text = "ThemeDefault"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/spacing" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/expand_to_edges" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/border_radius" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/layer" = { force = true; text = "Top"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/keyboard_interactivity" = { force = true; text = "OnDemand"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/margin" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/padding" = { force = true; text = "0"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/name" = { force = true; text = ''"Panel"''; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/output" = { force = true; text = ''"all"''; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/autohide" = { force = true; text = "None"; };
    "cosmic/com.system76.CosmicPanel.Panel/v1/autohover_delay_ms" = { force = true; text = "200"; };

    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center" = { force = true; text = "Some([])"; };

    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings" = {
      force = true;
      text = ''
        Some(([
            "com.system76.CosmicPanelLauncherButton",
            "com.system76.CosmicPanelWorkspacesButton",
            "com.system76.CosmicPanelAppButton",
            "com.system76.CosmicAppList",
            "com.system76.CosmicAppletMinimize",
        ], [
            "com.system76.CosmicAppletInputSources",
            "com.system76.CosmicAppletStatusArea",
            "com.system76.CosmicAppletA11y",
            "com.system76.CosmicAppletTiling",
            "com.system76.CosmicAppletAudio",
            "com.system76.CosmicAppletBluetooth",
            "com.system76.CosmicAppletNetwork",
            "com.system76.CosmicAppletBattery",
            "com.system76.CosmicAppletNotifications",
            "com.system76.CosmicAppletTime",
            "com.system76.CosmicAppletPower",
        ]))
      '';
    };

    # Panel entries - defines which panels are active
    "cosmic/com.system76.CosmicPanel/v1/entries" = {
      force = true;
      text = ''
        [
            "Panel",
        ]
      '';
    };

    # ── Theme Configuration ──
    "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" = { force = true; text = "true"; };
    "cosmic/com.system76.CosmicTheme.Mode/v1/auto_switch" = { force = true; text = "false"; };

    # Dark Theme Settings
    "cosmic/com.system76.CosmicTheme.Dark/v1/primary" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Dark/v1/secondary" = { force = true; text = "CosmicPalette"; };

    "cosmic/com.system76.CosmicTheme.Dark/v1/palette" = {
      force = true;
      text = ''
      (
          name: "cosmic-dark",
          bright_red: (
              red: 1.0,
              green: 0.627451,
              blue: 0.5647059,
              alpha: 1.0,
          ),
          bright_green: (
              red: 0.36862746,
              green: 0.85882354,
              blue: 0.54901963,
              alpha: 1.0,
          ),
          bright_orange: (
              red: 1.0,
              green: 0.6392157,
              blue: 0.49019608,
              alpha: 1.0,
          ),
          gray_1: (
              red: 0.105882354,
              green: 0.105882354,
              blue: 0.105882354,
              alpha: 1.0,
          ),
          gray_2: (
              red: 0.14901961,
              green: 0.14901961,
              blue: 0.14901961,
              alpha: 1.0,
          ),
          neutral_0: (
              red: 0.0,
              green: 0.0,
              blue: 0.0,
              alpha: 1.0,
          ),
          neutral_1: (
              red: 0.105882354,
              green: 0.105882354,
              blue: 0.105882354,
              alpha: 1.0,
          ),
          neutral_2: (
              red: 0.1882353,
              green: 0.1882353,
              blue: 0.1882353,
              alpha: 1.0,
          ),
          neutral_3: (
              red: 0.2784314,
              green: 0.2784314,
              blue: 0.2784314,
              alpha: 1.0,
          ),
          neutral_4: (
              red: 0.36862746,
              green: 0.36862746,
              blue: 0.36862746,
              alpha: 1.0,
          ),
          neutral_5: (
              red: 0.46666667,
              green: 0.46666667,
              blue: 0.46666667,
              alpha: 1.0,
          ),
          neutral_6: (
              red: 0.5686275,
              green: 0.5686275,
              blue: 0.5686275,
              alpha: 1.0,
          ),
          neutral_7: (
              red: 0.67058825,
              green: 0.67058825,
              blue: 0.67058825,
              alpha: 1.0,
          ),
          neutral_8: (
              red: 0.7764706,
              green: 0.7764706,
              blue: 0.7764706,
              alpha: 1.0,
          ),
          neutral_9: (
              red: 0.8862745,
              green: 0.8862745,
              blue: 0.8862745,
              alpha: 1.0,
          ),
          neutral_10: (
              red: 1.0,
              green: 1.0,
              blue: 1.0,
              alpha: 1.0,
          ),
          accent_blue: (
              red: 0.3882353,
              green: 0.8156863,
              blue: 0.8745098,
              alpha: 1.0,
          ),
          accent_indigo: (
              red: 0.6313726,
              green: 0.7529412,
              blue: 0.92156863,
              alpha: 1.0,
          ),
          accent_purple: (
              red: 0.90588236,
              green: 0.6117647,
              blue: 0.99607843,
              alpha: 1.0,
          ),
          accent_pink: (
              red: 1.0,
              green: 0.6117647,
              blue: 0.69411767,
              alpha: 1.0,
          ),
          accent_red: (
              red: 0.99215686,
              green: 0.6313726,
              blue: 0.627451,
              alpha: 1.0,
          ),
          accent_orange: (
              red: 1.0,
              green: 0.6784314,
              blue: 0.0,
              alpha: 1.0,
          ),
          accent_yellow: (
              red: 0.96862745,
              green: 0.8784314,
              blue: 0.38431373,
              alpha: 1.0,
          ),
          accent_green: (
              red: 0.57254905,
              green: 0.8117647,
              blue: 0.6117647,
              alpha: 1.0,
          ),
          accent_warm_grey: (
              red: 0.7921569,
              green: 0.7294118,
              blue: 0.7058824,
              alpha: 1.0,
          ),
          ext_warm_grey: (
              red: 0.60784316,
              green: 0.5568628,
              blue: 0.5411765,
              alpha: 1.0,
          ),
          ext_orange: (
              red: 1.0,
              green: 0.6784314,
              blue: 0.0,
              alpha: 1.0,
          ),
          ext_yellow: (
              red: 0.99607843,
              green: 0.85882354,
              blue: 0.2509804,
              alpha: 1.0,
          ),
          ext_blue: (
              red: 0.28235295,
              green: 0.7254902,
              blue: 0.78039217,
              alpha: 1.0,
          ),
          ext_purple: (
              red: 0.8117647,
              green: 0.49019608,
              blue: 1.0,
              alpha: 1.0,
          ),
          ext_pink: (
              red: 0.9764706,
              green: 0.22745098,
              blue: 0.5137255,
              alpha: 1.0,
          ),
          ext_indigo: (
              red: 0.24313726,
              green: 0.53333336,
              blue: 1.0,
              alpha: 1.0,
          ),
      )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Dark/v1/corner_radii" = {
      force = true;
      text = ''
        (
            radius_0: (0.0, 0.0, 0.0, 0.0),
            radius_xs: (4.0, 4.0, 4.0, 4.0),
            radius_s: (8.0, 8.0, 8.0, 8.0),
            radius_m: (16.0, 16.0, 16.0, 16.0),
            radius_l: (32.0, 32.0, 32.0, 32.0),
            radius_xl: (160.0, 160.0, 160.0, 160.0),
        )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Dark/v1/spacing" = {
      force = true;
      text = ''
        (
            space_none: 0,
            space_xxxs: 4,
            space_xxs: 4,
            space_xs: 8,
            space_s: 8,
            space_m: 16,
            space_l: 24,
            space_xl: 32,
            space_xxl: 48,
            space_xxxl: 64,
        )
      '';
    };

    # Dark Theme Builder Settings
    "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/corner_radii" = {
      force = true;
      text = ''
        (
            radius_0: [0.0, 0.0, 0.0, 0.0],
            radius_xs: [4.0, 4.0, 4.0, 4.0],
            radius_s: [8.0, 8.0, 8.0, 8.0],
            radius_m: [16.0, 16.0, 16.0, 16.0],
            radius_l: [32.0, 32.0, 32.0, 32.0],
            radius_xl: [160.0, 160.0, 160.0, 160.0],
        )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/spacing" = {
      force = true;
      text = ''
        (
            space_none: 0,
            space_xxxs: 4,
            space_xxs: 4,
            space_xs: 8,
            space_s: 8,
            space_m: 16,
            space_l: 24,
            space_xl: 32,
            space_xxl: 48,
            space_xxxl: 64,
        )
      '';
    };

    # Light Theme Settings
    "cosmic/com.system76.CosmicTheme.Light/v1/primary" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/secondary" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/accent" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/accent_button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/background" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/destructive" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/destructive_button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/icon_button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/link_button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/success" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/text_button" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/warning" = { force = true; text = "CosmicPalette"; };
    "cosmic/com.system76.CosmicTheme.Light/v1/warning_button" = { force = true; text = "CosmicPalette"; };

    "cosmic/com.system76.CosmicTheme.Light/v1/palette" = {
      force = true;
      text = ''
      (
          name: "cosmic-light",
          bright_red: (
              red: 0.5372549,
              green: 0.015686275,
              blue: 0.09411765,
              alpha: 1.0,
          ),
          bright_green: (
              red: 0.0,
              green: 0.34117648,
              blue: 0.17254902,
              alpha: 1.0,
          ),
          bright_orange: (
              red: 0.4745098,
              green: 0.17254902,
              blue: 0.0,
              alpha: 1.0,
          ),
          gray_1: (
              red: 0.8666667,
              green: 0.8666667,
              blue: 0.8666667,
              alpha: 1.0,
          ),
          gray_2: (
              red: 0.9098039,
              green: 0.9098039,
              blue: 0.9098039,
              alpha: 1.0,
          ),
          neutral_0: (
              red: 1.0,
              green: 1.0,
              blue: 1.0,
              alpha: 1.0,
          ),
          neutral_1: (
              red: 0.8862745,
              green: 0.8862745,
              blue: 0.8862745,
              alpha: 1.0,
          ),
          neutral_2: (
              red: 0.7764706,
              green: 0.7764706,
              blue: 0.7764706,
              alpha: 1.0,
          ),
          neutral_3: (
              red: 0.67058825,
              green: 0.67058825,
              blue: 0.67058825,
              alpha: 1.0,
          ),
          neutral_4: (
              red: 0.5686275,
              green: 0.5686275,
              blue: 0.5686275,
              alpha: 1.0,
          ),
          neutral_5: (
              red: 0.46666667,
              green: 0.46666667,
              blue: 0.46666667,
              alpha: 1.0,
          ),
          neutral_6: (
              red: 0.36862746,
              green: 0.36862746,
              blue: 0.36862746,
              alpha: 1.0,
          ),
          neutral_7: (
              red: 0.2784314,
              green: 0.2784314,
              blue: 0.2784314,
              alpha: 1.0,
          ),
          neutral_8: (
              red: 0.1882353,
              green: 0.1882353,
              blue: 0.1882353,
              alpha: 1.0,
          ),
          neutral_9: (
              red: 0.105882354,
              green: 0.105882354,
              blue: 0.105882354,
              alpha: 1.0,
          ),
          neutral_10: (
              red: 0.0,
              green: 0.0,
              blue: 0.0,
              alpha: 1.0,
          ),
          accent_blue: (
              red: 0.0,
              green: 0.32156864,
              blue: 0.3529412,
              alpha: 1.0,
          ),
          accent_indigo: (
              red: 0.18039216,
              green: 0.28627452,
              blue: 0.42745098,
              alpha: 1.0,
          ),
          accent_purple: (
              red: 0.40784314,
              green: 0.12941177,
              blue: 0.4862745,
              alpha: 1.0,
          ),
          accent_pink: (
              red: 0.5254902,
              green: 0.015686275,
              blue: 0.22745098,
              alpha: 1.0,
          ),
          accent_red: (
              red: 0.47058824,
              green: 0.16078432,
              blue: 0.18039216,
              alpha: 1.0,
          ),
          accent_orange: (
              red: 0.38431373,
              green: 0.2509804,
              blue: 0.0,
              alpha: 1.0,
          ),
          accent_yellow: (
              red: 0.3254902,
              green: 0.28235295,
              blue: 0.0,
              alpha: 1.0,
          ),
          accent_green: (
              red: 0.09411765,
              green: 0.33333334,
              blue: 0.16078432,
              alpha: 1.0,
          ),
          accent_warm_grey: (
              red: 0.33333334,
              green: 0.2784314,
              blue: 0.25882354,
              alpha: 1.0,
          ),
          ext_warm_grey: (
              red: 0.60784316,
              green: 0.5568628,
              blue: 0.5411765,
              alpha: 1.0,
          ),
          ext_orange: (
              red: 0.9843137,
              green: 0.72156864,
              blue: 0.42352942,
              alpha: 1.0,
          ),
          ext_yellow: (
              red: 0.96862745,
              green: 0.8784314,
              blue: 0.38431373,
              alpha: 1.0,
          ),
          ext_blue: (
              red: 0.41568628,
              green: 0.7921569,
              blue: 0.84705883,
              alpha: 1.0,
          ),
          ext_purple: (
              red: 0.8352941,
              green: 0.54901963,
              blue: 1.0,
              alpha: 1.0,
          ),
          ext_pink: (
              red: 1.0,
              green: 0.6117647,
              blue: 0.8666667,
              alpha: 1.0,
          ),
          ext_indigo: (
              red: 0.58431375,
              green: 0.76862746,
              blue: 0.9882353,
              alpha: 1.0,
          ),
      )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Light/v1/corner_radii" = {
      force = true;
      text = ''
        (
            radius_0: (0.0, 0.0, 0.0, 0.0),
            radius_xs: (4.0, 4.0, 4.0, 4.0),
            radius_s: (8.0, 8.0, 8.0, 8.0),
            radius_m: (16.0, 16.0, 16.0, 16.0),
            radius_l: (32.0, 32.0, 32.0, 32.0),
            radius_xl: (160.0, 160.0, 160.0, 160.0),
        )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Light/v1/spacing" = {
      force = true;
      text = ''
        (
            space_none: 0,
            space_xxxs: 4,
            space_xxs: 4,
            space_xs: 8,
            space_s: 8,
            space_m: 16,
            space_l: 24,
            space_xl: 32,
            space_xxl: 48,
            space_xxxl: 64,
        )
      '';
    };

    # Light Theme Builder Settings
    "cosmic/com.system76.CosmicTheme.Light.Builder/v1/corner_radii" = {
      force = true;
      text = ''
        (
            radius_0: [0.0, 0.0, 0.0, 0.0],
            radius_xs: [4.0, 4.0, 4.0, 4.0],
            radius_s: [8.0, 8.0, 8.0, 8.0],
            radius_m: [16.0, 16.0, 16.0, 16.0],
            radius_l: [32.0, 32.0, 32.0, 32.0],
            radius_xl: [160.0, 160.0, 160.0, 160.0],
        )
      '';
    };

    "cosmic/com.system76.CosmicTheme.Light.Builder/v1/spacing" = {
      force = true;
      text = ''
        (
            space_none: 0,
            space_xxxs: 4,
            space_xxs: 4,
            space_xs: 8,
            space_s: 8,
            space_m: 16,
            space_l: 24,
            space_xl: 32,
            space_xxl: 48,
            space_xxxl: 64,
        )
      '';
    };

    # ── Toolkit/Interface Settings ──
    "cosmic/com.system76.CosmicTk/v1/interface_density" = { force = true; text = "Compact"; };
    "cosmic/com.system76.CosmicTk/v1/header_size" = { force = true; text = "Compact"; };

    # ── Display Configuration ──
    "cosmic/com.system76.CosmicComp/v1/xdg_output_config" = {
      force = true;
      text = ''
        {
          "DP-2": (
            mode: ((3840, 2160), 59997),
            position: (0, 0),
            scale: 1.0,
            transform: Normal,
            vrr: false,
            enabled: true,
          ),
          "DP-3": (
            mode: ((3840, 2160), 59997),
            position: (3840, 0),
            scale: 1.0,
            transform: Normal,
            vrr: false,
            enabled: true,
          ),
        }
      '';
    };

    "cosmic/com.system76.CosmicComp/v1/primary_display" = { force = true; text = ''"DP-3"''; };

    # ── Input Settings ──
    "cosmic/com.system76.CosmicComp/v1/input" = {
      force = true;
      text = ''
        (
          keyboard: (
            repeat_delay: 600,
            repeat_rate: 25,
            layouts: ["us", "ru"],
            options: "grp:caps_toggle",
          ),
          touchpad: (
            click_method: Clickfinger,
            scroll_method: TwoFinger,
            tap_to_click: true,
            natural_scroll: true,
            accel_profile: Adaptive,
            accel_speed: 0.0,
          ),
          pointer: (
            natural_scroll: true,
            accel_profile: Flat,
            accel_speed: 0.0,
          ),
        )
      '';
    };

    # Input default settings - NOTE: Removed from declarative management
    # because COSMIC overwrites this file at runtime
    # See home.activation.cosmicInputSettings below for the actual implementation

    # ── Accessibility Settings ──
    "cosmic/com.system76.CosmicSettings.Accessibility/v1/config" = {
      force = true;
      text = ''
        (
          enable_screen_reader: false,
          enable_high_contrast: false,
          enable_large_text: false,
          enable_sticky_keys: false,
          enable_slow_keys: false,
          enable_bounce_keys: false,
        )
      '';
    };
  };

  # ── SSH Directory Permissions ──
  # Ensure ~/.ssh directory has correct permissions (700) for SSH to work properly
  # sops-nix creates this directory when placing SSH keys, but with incorrect permissions
  home.activation.fixSshPermissions = config.lib.dag.entryBefore ["writeBoundary"] ''
    if [ -d "$HOME/.ssh" ]; then
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"
      echo "Fixed ~/.ssh directory permissions to 700"
    fi
  '';

  # ── COSMIC Input Settings via Activation Script ──
  # COSMIC overwrites config files at runtime, breaking symlinks
  # So we use activation scripts to copy (not symlink) the settings on each rebuild
  home.activation.cosmicInputSettings = config.lib.dag.entryAfter ["writeBoundary"] ''
    INPUT_DEFAULT="$HOME/.config/cosmic/com.system76.CosmicComp/v1/input_default"
    mkdir -p "$(dirname "$INPUT_DEFAULT")"

    cat > "$INPUT_DEFAULT" <<'EOF'
(
    state: Enabled,
    scroll_config: Some((
        method: Some(TwoFinger),
        natural_scroll: Some(true),
    )),
    acceleration: Some((
        profile: Some(Flat),
        speed: 0.0,
    )),
)
EOF

    $DRY_RUN_CMD chmod 644 "$INPUT_DEFAULT"
    echo "Applied COSMIC input settings (natural scroll + flat acceleration)"
  '';

  # ── SSH Public Keys with Secret Emails ──
  # Build id_dilcher.pub using the email-work secret
  home.activation.sshDilcherPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-work ]; then
      EMAIL_WORK=$(cat /run/secrets/email-work)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzWSM7wSnAL65rJXZaDgcMo9ZmPKM1ZfhZaS9QF5GVD $EMAIL_WORK"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_dilcher.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_dilcher.pub"
      echo "Created id_dilcher.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-work not found, skipping id_dilcher.pub creation"
    fi
  '';

  # Build id_github.pub using the email-gmail secret
  home.activation.sshGithubPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-gmail ]; then
      EMAIL_GMAIL=$(cat /run/secrets/email-gmail)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFPV4++2NsKJGEs8q9U0CTQ0S1jYLW6nGU/0Xx5F8mC $EMAIL_GMAIL"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_github.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github.pub"
      echo "Created id_github.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-gmail not found, skipping id_github.pub creation"
    fi
  '';

  # Build id_iztiev.pub using the email-gmail secret
  home.activation.sshIztievPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-gmail ]; then
      EMAIL_GMAIL=$(cat /run/secrets/email-gmail)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/gHKm75N4OZmAWl/NjzNSGVJFlcN8nqMiElDQoTgzF $EMAIL_GMAIL"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_iztiev.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_iztiev.pub"
      echo "Created id_iztiev.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-gmail not found, skipping id_iztiev.pub creation"
    fi
  '';

  # Build id_hetzner.pub using the email-proton secret
  home.activation.sshHetznerPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-proton ]; then
      EMAIL_PROTON=$(cat /run/secrets/email-proton)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8c0Yv+V3h3wV5dH7dYp3Rp6IC6FwpUOEaU213jPxJ7 $EMAIL_PROTON"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_hetzner.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_hetzner.pub"
      echo "Created id_hetzner.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-proton not found, skipping id_hetzner.pub creation"
    fi
  '';

  home.stateVersion = "25.11";
}
