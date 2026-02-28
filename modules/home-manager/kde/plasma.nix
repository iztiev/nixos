{ ... }:

{
  # ── KDE Plasma Configuration ──
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    input = {
      keyboard = {
        layouts = [
          { layout = "us"; }
          { layout = "ru"; }
        ];
      };

      mice = [
        {
          name = "Logitech G304";
          vendorId = "046d";
          productId = "4074";
          naturalScroll = true;
          accelerationProfile = "none";
        }
      ];
    };

    configFile = {
      # Global KDE settings
      kdeglobals = {
        KScreen = {
          ScaleFactor = 1;
          ScreenScaleFactors = "1";
        };
        General.BrowserApplication = "firefox.desktop";
      };

      # Font DPI settings (96 = 100%)
      kcmfonts.General.forceFontDPI = 96;

      # KWin Wayland settings
      kwinrc = {
        Xwayland.Scale = 1;
        TabBox.MultiScreenMode = 1;
      };

      # Session Management - start with empty session
      ksmserverrc.General = {
        loginMode = "emptySession";
        confirmLogout = false;
      };

      # Caps Lock as keyboard layout toggle (not exposed as high-level option)
      kxkbrc.Layout.Options = "grp:caps_toggle";
    };
  };

}
