{ config, pkgs, lib, ... }:
{
  # ── Printing (CUPS) ──
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint              # High-quality printer drivers
      epson-escpr             # Epson ESC/P-R driver
      epson-escpr2            # Epson ESC/P-R driver (newer models)
    ];
  };

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ── Scanning (SANE) ──
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan           # Network scanner support (eSCL/WSD)
    ];
    # Default sane-backends includes epson2 backend which supports L3258
  };

  # Add user to scanner group
  users.users.iztiev.extraGroups = [ "scanner" "lp" ];

  # ── Printer/Scanner Management Applications ──
  environment.systemPackages = with pkgs; [
    system-config-printer  # GUI for managing printers
    simple-scan            # Simple scanning application
  ];
}
