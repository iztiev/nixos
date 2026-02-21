{ config, pkgs, lib, ... }:
{
  # ── Secure Boot via Lanzaboote ──
  # Lanzaboote replaces systemd-boot — must force it off
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
