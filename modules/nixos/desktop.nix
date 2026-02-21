{ config, pkgs, lib, ... }:
{
  # ── Desktop Environment: KDE Plasma 6 ──
  services.desktopManager.plasma6.enable = true;

  # ── Display Manager: SDDM (Wayland) ──
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Run SDDM itself on Wayland
  };

  # ── Auto-login ──
  services.displayManager.autoLogin = {
    enable = true;
    user = "iztiev";
  };

  # ── Exclude unwanted default KDE packages ──
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa    # Music player
    kwrited  # Wall message daemon
  ];

  # ── Helpful KDE extras ──
  environment.systemPackages = with pkgs.kdePackages; [
    sddm-kcm         # SDDM settings in System Settings
    partitionmanager # KDE Partition Manager
  ];
}
