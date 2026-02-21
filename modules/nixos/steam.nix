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

    # ── Additional Gaming Packages ──
    environment.systemPackages = with pkgs; [
      steam-run  # Run non-Steam games in Steam runtime environment
    ];
  };
}
