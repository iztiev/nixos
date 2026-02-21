{ config, pkgs, lib, ... }:
{
  # ── Nix Settings ──
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Boot ──
  boot.loader.efi.canTouchEfiVariables = true;
  # systemd-boot is the default; secure-boot.nix overrides it with lanzaboote
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.editor = false;

  # LUKS tuning for NVMe SSDs
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/2029b089-eab2-4923-95ef-b94b757f5f74";
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true;

  # AMD CPU
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = true;

  # ── Networking ──
  networking.hostName = "rhea";
  networking.networkmanager.enable = true;

  # ── ZeroTier ──
  services.zerotierone.enable = true;

  # ── Locale & Time ──
  time.timeZone = "Asia/Almaty";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Audio (PipeWire — required for Wayland screen sharing) ──
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Flatpak ──
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "com.slack.Slack"
    "org.telegram.desktop"
  ];
  services.flatpak.update.onActivation = true;

  # ── Electron/Chromium Wayland support ──
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Qt/KDE Scaling (Wayland) ──
  environment.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";  # Enable automatic scaling
    QT_SCALE_FACTOR = "1";              # 1 = 100%, 1.25 = 125%, 1.5 = 150%
    QT_SCREEN_SCALE_FACTORS = "1";      # Per-screen scaling
    GDK_SCALE = "1";                    # GTK apps scaling (integer only)
    GDK_DPI_SCALE = "1";                # GTK DPI scaling (fine-tune)
  };

  # ── Users ──
  users.users.iztiev = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # ── System Packages ──
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    sbctl               # Secure Boot key management
    nvidia-vaapi-driver # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
