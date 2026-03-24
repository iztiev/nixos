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
      description = "Enable GE-Proton (GloriousEggroll's custom Proton build)";
    };

    leManUltimate = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Le Mans Ultimate support (custom Proton build required)";
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
        lutris      # Open gaming platform for managing games from multiple sources
        gamescope   # Wayland micro-compositor for better fullscreen support
        mangohud    # Gaming performance overlay
      ]
      # ── Le Mans Ultimate ──
      # Requires custom Proton: GE-Proton10-25-LMU-hid_fixes
      # Install: extract to ~/.steam/steam/compatibilitytools.d/
      # Then select it in LMU's Steam compatibility settings
      # Also set CEF Mode to 2 in LMU Settings.JSON to fix UI rendering
      ++ optionals config.services.steam.leManUltimate [
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
