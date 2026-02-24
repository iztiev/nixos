{ config, pkgs, lib, ... }:
{
  # ── Secure Boot via Lanzaboote ──
  # Lanzaboote replaces systemd-boot — must force it off
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  # Use maximum available resolution (UHD/4K)
  boot.loader.systemd-boot.consoleMode = "max";
  # Auto-boot after 2 seconds
  boot.loader.timeout = 2;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
