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
    # Development
    claude-code

    # Utilities
    htop
    ripgrep
    fd
    unzip

    # Internet
    chromium
    qbittorrent

    # Ofiice
    libreoffice-qt
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

  # ── Default Applications ──
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  # ── KDE Plasma Configuration ──
  programs.plasma = {
    enable = true;

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

  # ── KDE Plasma Desktop Applets Configuration ──
  # Declaratively manage Plasma desktop panel layout and applets
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
    force = true;
    text = ''
      [ActionPlugins][0]
      MiddleButton;NoModifier=org.kde.paste
      RightButton;NoModifier=org.kde.contextmenu

      [ActionPlugins][1]
      RightButton;NoModifier=org.kde.contextmenu

      [Containments][197]
      activityId=
      formfactor=2
      immutability=1
      lastScreen[$i]=0
      location=4
      plugin=org.kde.panel
      wallpaperplugin=org.kde.image

      [Containments][197][Applets][198]
      immutability=1
      plugin=org.kde.plasma.kickoff

      [Containments][197][Applets][198][Configuration]
      popupHeight=509
      popupWidth=647

      [Containments][197][Applets][198][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][197][Applets][198][Configuration][General]
      favoritesPortedToKAstats=true

      [Containments][197][Applets][199]
      immutability=1
      plugin=org.kde.plasma.icontasks

      [Containments][197][Applets][199][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][197][Applets][199][Configuration][General]
      groupingStrategy=0
      launchers=applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:chromium-browser.desktop,applications:pycharm.desktop,applications:webstorm.desktop
      middleClickAction=Close
      showOnlyCurrentScreen=true

      [Containments][197][Applets][200]
      immutability=1
      plugin=org.kde.plasma.marginsseparator

      [Containments][197][Applets][201]
      activityId=
      formfactor=0
      immutability=1
      lastScreen=-1
      location=0
      plugin=org.kde.plasma.systemtray
      popupHeight=432
      popupWidth=432
      wallpaperplugin=org.kde.image

      [Containments][197][Applets][201][Applets][202]
      immutability=1
      plugin=org.kde.plasma.manage-inputmethod

      [Containments][197][Applets][201][Applets][203]
      immutability=1
      plugin=org.kde.plasma.notifications

      [Containments][197][Applets][201][Applets][204]
      immutability=1
      plugin=org.kde.plasma.clipboard

      [Containments][197][Applets][201][Applets][205]
      immutability=1
      plugin=org.kde.plasma.devicenotifier

      [Containments][197][Applets][201][Applets][206]
      immutability=1
      plugin=org.kde.plasma.cameraindicator

      [Containments][197][Applets][201][Applets][207]
      immutability=1
      plugin=org.kde.plasma.keyboardlayout

      [Containments][197][Applets][201][Applets][208]
      immutability=1
      plugin=org.kde.plasma.volume

      [Containments][197][Applets][201][Applets][208][Configuration][General]
      migrated=true

      [Containments][197][Applets][201][Applets][209]
      immutability=1
      plugin=org.kde.plasma.networkmanagement

      [Containments][197][Applets][201][Applets][210]
      immutability=1
      plugin=org.kde.plasma.printmanager

      [Containments][197][Applets][201][Applets][211]
      immutability=1
      plugin=org.kde.plasma.weather

      [Containments][197][Applets][201][Applets][212]
      immutability=1
      plugin=org.kde.plasma.keyboardindicator

      [Containments][197][Applets][201][Applets][213]
      immutability=1
      plugin=org.kde.kscreen

      [Containments][197][Applets][201][Applets][237]
      immutability=1
      plugin=org.kde.plasma.brightness

      [Containments][197][Applets][201][Applets][238]
      immutability=1
      plugin=org.kde.plasma.battery

      [Containments][197][Applets][201][Applets][242]
      immutability=1
      plugin=org.kde.plasma.mediacontroller

      [Containments][197][Applets][201][General]
      extraItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen
      knownItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen

      [Containments][197][Applets][214]
      immutability=1
      plugin=org.kde.plasma.digitalclock

      [Containments][197][Applets][214][Configuration]
      popupHeight=400
      popupWidth=560

      [Containments][197][Applets][215]
      immutability=1
      plugin=org.kde.plasma.showdesktop

      [Containments][197][General]
      AppletOrder=198;199;200;201;214;215

      [Containments][216]
      activityId=
      formfactor=2
      immutability=1
      lastScreen[$i]=1
      location=4
      plugin=org.kde.panel
      wallpaperplugin=org.kde.image

      [Containments][216][Applets][217]
      immutability=1
      plugin=org.kde.plasma.kickoff

      [Containments][216][Applets][217][Configuration]
      popupHeight=509
      popupWidth=647

      [Containments][216][Applets][217][Configuration][General]
      favoritesPortedToKAstats=true

      [Containments][216][Applets][218]
      immutability=1
      plugin=org.kde.plasma.icontasks

      [Containments][216][Applets][218][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][216][Applets][218][Configuration][General]
      groupingStrategy=0
      launchers=applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:chromium-browser.desktop,applications:pycharm.desktop,applications:webstorm.desktop
      middleClickAction=Close
      showOnlyCurrentScreen=true

      [Containments][216][Applets][219]
      immutability=1
      plugin=org.kde.plasma.marginsseparator

      [Containments][216][Applets][220]
      activityId=
      formfactor=0
      immutability=1
      lastScreen=-1
      location=0
      plugin=org.kde.plasma.systemtray
      popupHeight=432
      popupWidth=432
      wallpaperplugin=org.kde.image

      [Containments][216][Applets][220][Applets][221]
      immutability=1
      plugin=org.kde.plasma.manage-inputmethod

      [Containments][216][Applets][220][Applets][222]
      immutability=1
      plugin=org.kde.plasma.notifications

      [Containments][216][Applets][220][Applets][223]
      immutability=1
      plugin=org.kde.plasma.clipboard

      [Containments][216][Applets][220][Applets][224]
      immutability=1
      plugin=org.kde.plasma.devicenotifier

      [Containments][216][Applets][220][Applets][225]
      immutability=1
      plugin=org.kde.plasma.cameraindicator

      [Containments][216][Applets][220][Applets][226]
      immutability=1
      plugin=org.kde.plasma.keyboardlayout

      [Containments][216][Applets][220][Applets][227]
      immutability=1
      plugin=org.kde.plasma.volume

      [Containments][216][Applets][220][Applets][227][Configuration][General]
      migrated=true

      [Containments][216][Applets][220][Applets][228]
      immutability=1
      plugin=org.kde.plasma.networkmanagement

      [Containments][216][Applets][220][Applets][229]
      immutability=1
      plugin=org.kde.plasma.printmanager

      [Containments][216][Applets][220][Applets][230]
      immutability=1
      plugin=org.kde.plasma.weather

      [Containments][216][Applets][220][Applets][231]
      immutability=1
      plugin=org.kde.plasma.keyboardindicator

      [Containments][216][Applets][220][Applets][232]
      immutability=1
      plugin=org.kde.kscreen

      [Containments][216][Applets][220][Applets][239]
      immutability=1
      plugin=org.kde.plasma.brightness

      [Containments][216][Applets][220][Applets][240]
      immutability=1
      plugin=org.kde.plasma.battery

      [Containments][216][Applets][220][Applets][241]
      immutability=1
      plugin=org.kde.plasma.mediacontroller

      [Containments][216][Applets][220][General]
      extraItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen
      knownItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen

      [Containments][216][Applets][233]
      immutability=1
      plugin=org.kde.plasma.digitalclock

      [Containments][216][Applets][233][Configuration]
      popupHeight=400
      popupWidth=560

      [Containments][216][Applets][234]
      immutability=1
      plugin=org.kde.plasma.showdesktop

      [Containments][216][General]
      AppletOrder=217;218;219;220;233;234

      [Containments][235]
      ItemGeometries-3840x2160=
      ItemGeometriesHorizontal=
      activityId=00c4b352-5d74-46f9-ab53-ab3a14d5ed49
      formfactor=0
      immutability=1
      lastScreen=0
      location=0
      plugin=org.kde.plasma.folder
      wallpaperplugin=org.kde.image

      [Containments][236]
      ItemGeometries-3840x2160=
      ItemGeometriesHorizontal=
      activityId=00c4b352-5d74-46f9-ab53-ab3a14d5ed49
      formfactor=0
      immutability=1
      lastScreen=1
      location=0
      plugin=org.kde.plasma.folder
      wallpaperplugin=org.kde.image

      [ScreenMapping]
      itemsOnDisabledScreens=
    '';
  };

  # KDE Plasma Shell configuration
  xdg.configFile."plasmashellrc" = {
    force = true;
    text = ''
      [PlasmaViews][Panel 197]
      floating=1

      [PlasmaViews][Panel 197][Defaults]
      thickness=44

      [PlasmaViews][Panel 216]
      floating=1

      [PlasmaViews][Panel 216][Defaults]
      thickness=44

      [Updates]
      performed=/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/systemloadviewer_systemmonitor.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/unlock_widgets.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/mediaframe_migrate_useBackground_setting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/containmentactions_middlebutton.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_remove_shortcut.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_font_settings.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_migrateiconsetting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/no_middle_click_paste_on_panels.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_rename_timezonedisplay_key.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_showseconds_setting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/move_desktop_layout_config.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/migrate_font_weights.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/maintain_existing_desktop_icon_sizes.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/klipper_clear_config.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/taskmanager_configUpdate_wheelEnabled.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/folderview_fix_recursive_screenmapping.js
    '';
  };

  # KDE Konsole configuration
  xdg.configFile."konsolerc" = {
    force = true;
    text = ''
      [Desktop Entry]
      DefaultProfile=Izosevka.profile

      [General]
      ConfigVersion=1

      [KonsoleWindow]
      ShowMenuBarByDefault=false

      [Notification Messages]
      CloseSessionsWithProcesses=false

      [UiSettings]
      ColorScheme=
    '';
  };

  # KDE Konsole profile (in ~/.local/share/konsole/)
  xdg.dataFile."konsole/Izosevka.profile" = {
    force = true;
    text = ''
      [Appearance]
      Font=Izosevka,16,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

      [General]
      Name=Izosevka
      Parent=FALLBACK/

      [Scrolling]
      HistoryMode=2
    '';
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
