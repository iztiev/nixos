{ config, pkgs, lib, ... }:

with lib;

{
  options.services.kde = {
    enable = mkEnableOption "KDE Plasma 6 desktop environment";

    autoLogin = {
      enable = mkEnableOption "automatic login";
      user = mkOption {
        type = types.str;
        default = "";
        description = "User to automatically log in";
      };
    };

    excludePackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs.kdePackages; [
        elisa    # Music player
        kwrited  # Wall message daemon
      ];
      description = "KDE packages to exclude from the default installation";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs.kdePackages; [
        sddm-kcm         # SDDM settings in System Settings
        partitionmanager # KDE Partition Manager
      ];
      description = "Additional KDE packages to install";
    };

    scaling = {
      qtScaleFactor = mkOption {
        type = types.str;
        default = "1";
        description = "Qt scale factor (1 = 100%, 1.25 = 125%, 1.5 = 150%)";
      };

      gdkScale = mkOption {
        type = types.str;
        default = "1";
        description = "GTK apps scaling (integer only)";
      };

      gdkDpiScale = mkOption {
        type = types.str;
        default = "1";
        description = "GTK DPI scaling (fine-tune)";
      };
    };
  };

  config = mkIf config.services.kde.enable {
    # ── Desktop Environment: KDE Plasma 6 ──
    services.desktopManager.plasma6.enable = true;

    # ── Display Manager: SDDM (Wayland) ──
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true; # Run SDDM itself on Wayland
    };

    # ── Auto-login ──
    services.displayManager.autoLogin = mkIf config.services.kde.autoLogin.enable {
      enable = true;
      user = config.services.kde.autoLogin.user;
    };

    # ── Exclude unwanted default KDE packages ──
    environment.plasma6.excludePackages = config.services.kde.excludePackages;

    # ── KDE packages ──
    environment.systemPackages = config.services.kde.extraPackages;

    # ── Qt/KDE Scaling (Wayland) ──
    environment.sessionVariables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";  # Enable automatic scaling
      QT_SCALE_FACTOR = config.services.kde.scaling.qtScaleFactor;
      QT_SCREEN_SCALE_FACTORS = config.services.kde.scaling.qtScaleFactor;
      GDK_SCALE = config.services.kde.scaling.gdkScale;
      GDK_DPI_SCALE = config.services.kde.scaling.gdkDpiScale;
    };
  };
}
