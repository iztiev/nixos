{ config, pkgs, lib, ... }:
{
  # ── Nix Settings ──
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ../overlays/default.nix) ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  systemd.services.nix-daemon.environment = {
    https_proxy = "socks5h://127.0.0.1:1080";
  };

  # ── Boot ──
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.editor = true;

  # Large NVMEs support
  boot.kernelParams = [ "amd_iommu=pt" ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Simagic force feedback wheel driver
  # boot.extraModulePackages = [
  #   (config.boot.kernelPackages.callPackage ../pkgs/simagic-ff.nix { })
  # ];
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="3670", MODE="0666", TAG+="uaccess"
  '';

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
  networking.networkmanager.wifi.backend = "iwd";  # Use iwd backend
  networking.wireless.enable = false;  # Disable wpa_supplicant
  # Disable WiFi by blacklisting common WiFi kernel modules
  boot.blacklistedKernelModules = [ "iwlwifi" "iwlmvm" "ath9k" "ath10k" "rtw88" "mt76" ];

  # ── ZeroTier ──
  services.zerotierone.enable = true;

  # ── Docker ──
  services.docker-custom = {
    enable = true;
    useNvidiaGpu = true;
  };

  # ── Locale & Time ──
  time.timeZone = "Asia/Almaty";
  time.hardwareClockInLocalTime = true; # Windows dual-boot: keep RTC in local time
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings.LC_TIME = "de_DE.UTF-8";    # DD.MM.YYYY date format, 24-hour clock
  i18n.extraLocaleSettings.LC_NUMERIC = "ru_RU.UTF-8"; # 1 234 567,89 number format
  i18n.extraLocaleSettings.LC_PAPER = "de_DE.UTF-8";   # A4 paper format

  # ── Audio (PipeWire — required for Wayland screen sharing) ──
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Disable suspend-on-idle to prevent audio devices from sleeping
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-disable-suspension.conf" ''
        wireplumber.profiles = {
          main = {
            hooks.node.suspend = disabled
          }
        }
      '')
    ];
  };

  # Disable ALSA power saving (prevents hardware from sleeping)
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options snd_ac97_codec power_save=0
  '';

  # ── Electron/Chromium Wayland support ──
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Desktop Environment (KDE Plasma 6) ──
  services.kde.enable = true;

  # ── Steam ──
  services.steam.enable = true;

  # ── Flatpak ──
  services.flatpak.enable = false;

  # ── WoeUSB ──
  programs.woeusb.enable = true;

  # ── NCALayer ──
  programs.ncalayer = {
    enable = true;
    installCerts = true;
  };

  # ── Sops Configuration ──
  sops.secrets.iztiev-password.neededForUsers = true;

  # Copy sops age key to user directory for home-manager sops access
  systemd.services.copy-sops-key-to-user = {
    description = "Copy sops age key to iztiev user directory";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      USER_SOPS_DIR="/home/iztiev/.config/sops/age"
      USER_KEY_FILE="$USER_SOPS_DIR/keys.txt"
      SYSTEM_KEY_FILE="/var/lib/sops-nix/key.txt"

      if [ -f "$SYSTEM_KEY_FILE" ]; then
        # Create directory if it doesn't exist
        mkdir -p "$USER_SOPS_DIR"

        # Copy the key file
        cp "$SYSTEM_KEY_FILE" "$USER_KEY_FILE"

        # Set ownership and permissions
        chown iztiev:users "$USER_SOPS_DIR"
        chown iztiev:users "$USER_KEY_FILE"
        chmod 0700 "$USER_SOPS_DIR"
        chmod 0600 "$USER_KEY_FILE"

        echo "Sops key copied to user directory"
      else
        echo "Warning: System sops key not found at $SYSTEM_KEY_FILE"
      fi
    '';
  };

  users.mutableUsers = false;

  # ── Users ──
  users.users.iztiev = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.iztiev-password.path;
    extraGroups = [ "networkmanager" "wheel" "input" "video" ];
  };

  # ── System Packages ──
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    nvidia-vaapi-driver # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
