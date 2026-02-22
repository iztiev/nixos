{ config, pkgs, lib, ... }:
{
  # ── GPU: NVIDIA RTX 4080 Super ──
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam, Wine, 32-bit OpenGL apps
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is REQUIRED for Wayland compositors
    modesetting.enable = true;

    # Open-source kernel module — recommended for RTX 40 series (Ada Lovelace)
    # Only the kernel module is open; userspace libraries remain proprietary
    open = true;

    # Power management (disable for desktops; only useful for laptops)
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;

    # Driver branch: stable (default), beta, or production
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # ── Wayland + NVIDIA environment variables ──
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
