{ config, ... }:

{
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
        TabBox = {
          MultiScreenMode=1;
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

  # Keyboard layout settings
  xdg.configFile."kxkbrc" = {
    source = ./files/kxkbrc;
    force = true;
  };

  # Mouse settings - use activation to copy (not symlink) so it's writable
  # Run BEFORE writeBoundary to ensure file exists before plasma-manager tries to write
  home.activation.kcminputrc = config.lib.dag.entryBefore ["writeBoundary"] ''
    mkdir -p "$HOME/.config"
    # Remove any existing symlink or file
    rm -f "$HOME/.config/kcminputrc"
    # Copy the file and make it writable
    cp -f ${./files/kcminputrc} "$HOME/.config/kcminputrc"
    chmod 644 "$HOME/.config/kcminputrc"
  '';
}
