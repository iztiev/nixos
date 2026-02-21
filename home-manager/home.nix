{ config, pkgs, inputs, ... }:
{
  home.username = "iztiev";
  home.homeDirectory = "/home/iztiev";

  # ── User Packages ──
  home.packages = with pkgs; [
    # Browsers
    chromium

    # Development
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
      };
    };
  };

  # ── Git ──
  programs.git = {
    enable = true;
    settings = {
      user.name = "Timur Izmagambetov";
      user.email = "iztiev@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
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

  home.stateVersion = "25.11";
}
