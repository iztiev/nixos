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

    # CachyOS fix for Linux 6.19+ kernel
    # package = 
    # let
    #   base = config.boot.kernelPackages.nvidiaPackages.latest;
    #   cachyos-nvidia-patch = pkgs.fetchpatch {
    #     url="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
    #     sha256="sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
    #   };

    #   driverAttr = if config.hardware.nvidia.open then "open" else "bin";
    # in
    # base
    # // {
    #     ${driverAttr} = base.${driverAttr}.overrideAttrs (oldAttrs: {
    #       patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
    #     });
    #   };

    # Driver branch: stable (default), beta, or production
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # ── Wayland + NVIDIA environment variables ──
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    # Expose NVIDIA/CUDA libraries to prebuilt binaries (e.g. LM Studio)
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # nvtop - htop for gpu
  ];
}
