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
  # boot.loader.timeout = 2;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Motherboard was replaced — new TPM chip can't load old anchor secret.
  # LUKS is passphrase-based so TPM sealing is not used; disable the failing service.
  systemd.services.systemd-tpm2-setup.enable = false;

  # ── Windows 11 boot entry ──
  # Syncs the full EFI/Microsoft/Boot/ directory from the Windows EFI partition
  # (nvme1n1p1) into the NixOS ESP. bootmgfw.efi is stored as windows.efi so
  # systemd-boot does not auto-detect it (it only scans for "bootmgfw.efi"),
  # eliminating the duplicate "Windows Boot Manager" entry. BCD and all other
  # support files remain in place so Windows Boot Manager can locate the OS.
  system.activationScripts.windows-efi-sync = {
    text = ''
      WIN_MOUNT=$(${pkgs.coreutils}/bin/mktemp -d)
      if ${pkgs.util-linux}/bin/mount -t vfat UUID=96A9-374D "$WIN_MOUNT" -o ro,noatime 2>/dev/null; then
        if [ -d "$WIN_MOUNT/EFI/Microsoft/Boot" ]; then
          ${pkgs.coreutils}/bin/mkdir -p /boot/EFI/Microsoft
          ${pkgs.rsync}/bin/rsync -a --delete --exclude='bootmgfw.efi' \
            "$WIN_MOUNT/EFI/Microsoft/Boot/" /boot/EFI/Microsoft/Boot/
          ${pkgs.coreutils}/bin/cp -f \
            "$WIN_MOUNT/EFI/Microsoft/Boot/bootmgfw.efi" \
            /boot/EFI/Microsoft/Boot/windows.efi
        fi
        ${pkgs.util-linux}/bin/umount "$WIN_MOUNT"
      fi
      ${pkgs.coreutils}/bin/rmdir "$WIN_MOUNT"
    '';
    deps = [];
  };

  # Write the loader entry after lanzaboote has managed its own entries.
  # z- prefix sorts it last in the boot menu (after all NixOS generations).
  system.activationScripts.windows-boot-entry = {
    text = ''
      ${pkgs.coreutils}/bin/mkdir -p /boot/loader/entries
      printf 'title   Windows 11\nefi     /EFI/Microsoft/Boot/windows.efi\n' \
        > /boot/loader/entries/z-windows.conf
    '';
    deps = [ "windows-efi-sync" ];
  };
}
