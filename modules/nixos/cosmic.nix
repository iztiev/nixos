{ config, pkgs, lib, ... }:

with lib;

{
  options.services.cosmic = {
    enable = mkEnableOption "COSMIC desktop environment";

    autoLogin = {
      enable = mkEnableOption "automatic login";
      user = mkOption {
        type = types.str;
        default = "";
        description = "User to automatically log in";
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional COSMIC packages to install";
    };
  };

  config = mkIf config.services.cosmic.enable {
    # ── Desktop Environment: COSMIC ──
    services.desktopManager.cosmic.enable = true;

    # ── Display Manager: COSMIC Greeter ──
    services.displayManager.cosmic-greeter.enable = true;

    # ── Auto-login ──
    services.displayManager.autoLogin = mkIf config.services.cosmic.autoLogin.enable {
      enable = true;
      user = config.services.cosmic.autoLogin.user;
    };

    # ── Additional packages ──
    environment.systemPackages = config.services.cosmic.extraPackages;

    # ── XDG Desktop Portal for Wayland support ──
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
      config.common.default = "*";
    };
  };
}
