{ config, pkgs, lib, ... }:

with lib;

{
  options.programs.woeusb = {
    enable = mkEnableOption "WoeUSB - Windows USB creation tool with UEFI:NTFS support";

    includeNtfs3g = mkOption {
      type = types.bool;
      default = true;
      description = "Include NTFS-3G for better NTFS filesystem support";
    };
  };

  config = mkIf config.programs.woeusb.enable {
    # ── WoeUSB Package ──
    # WoeUSB is a tool for creating Windows installation USB drives from Linux
    # Supports both Legacy BIOS and UEFI boot modes
    environment.systemPackages = with pkgs; [
      woeusb           # Main WoeUSB tool with UEFI:NTFS support

      # Additional tools for USB management
      parted           # Partition management
      gptfdisk         # GPT partition table editor
      dosfstools       # FAT filesystem utilities

      # NTFS support (optional but recommended)
      (mkIf config.programs.woeusb.includeNtfs3g ntfs3g)
    ];

    # ── USB Device Access ──
    # Allow users to access USB devices without root
    services.udev.extraRules = ''
      # WoeUSB needs raw device access to create bootable USB drives
      # This allows users in the 'users' group to write to USB devices
      SUBSYSTEM=="block", ATTRS{removable}=="1", GROUP="users", MODE="0660"
    '';

    # ── Kernel Modules ──
    # Ensure required filesystem modules are loaded
    boot.kernelModules = [
      "vfat"      # FAT32 for UEFI boot partition
      "exfat"     # exFAT support
    ] ++ optional config.programs.woeusb.includeNtfs3g "ntfs3";  # NTFS support (kernel 5.15+)

    # ── Filesystem Support ──
    boot.supportedFilesystems = [
      "vfat"      # UEFI boot partition
      "ntfs"      # Windows installation files
      "exfat"     # Alternative filesystem
    ];
  };
}
