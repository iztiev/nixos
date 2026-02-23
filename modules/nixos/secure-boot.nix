{ config, pkgs, lib, ... }:
{
  # ── Secure Boot via Lanzaboote ──
  # Lanzaboote replaces systemd-boot — must force it off
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
