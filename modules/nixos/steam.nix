{ config, pkgs, lib, ... }:

with lib;

{
  options.services.steam = {
    enable = mkEnableOption "Steam gaming platform";

    remotePlay = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Steam Remote Play";
    };

    dedicatedServer = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Steam Dedicated Server support";
    };

    gamescopeSession = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Gamescope session for Steam Big Picture mode";
    };

    protonGE = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GE-Proton (GloriousEggroll's custom Proton build), including Protornup-QT and ProtonTricks";
    };
  };

  config = mkIf config.services.steam.enable {
    # ── Steam ──
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = config.services.steam.remotePlay;
      dedicatedServer.openFirewall = config.services.steam.dedicatedServer;
      gamescopeSession.enable = config.services.steam.gamescopeSession;
      extraCompatPackages = mkIf config.services.steam.protonGE [
        pkgs.proton-ge-bin
      ];
    };

    # ── Hardware Support ──
    # Enable 32-bit graphics driver support for gaming
    hardware.graphics.enable32Bit = true;

    # ── Gaming Performance ──
    programs.gamemode.enable = true;  # CPU governor optimization for games

    # ── Additional Gaming Packages ──
    environment.systemPackages = with pkgs;
      [
        steam-run   # Run non-Steam games in Steam runtime environment
        # lutris      # Open gaming platform for managing games from multiple sources. Disabled because it is shipped with defunct openldap v2.6.13
        gamescope   # Wayland micro-compositor for better fullscreen support
        mangohud    # Gaming performance overlay
      ]
      # ── Proton GE ──
      # Install Protonup-QT and ProtonTricks with proton-ge
      ++ optionals config.services.steam.protonGE [
        protontricks  # Per-game Proton prefix management
        protonup-qt   # GUI for managing custom Proton builds
      ];

    # ── Steam Environment Variables ──
    # Force Steam to use Wayland with better fullscreen handling
    environment.sessionVariables = {
      SDL_VIDEODRIVER = "wayland";
      ENABLE_VKBASALT = "1";
    };
  };
}
