{ config, pkgs, lib, inputs, ... }:
{
  # ── Nix Settings ──
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ../overlays/default.nix { inherit inputs; system = "x86_64-linux"; }) ];
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
  boot.kernelParams = [ "amd_iommu=off" ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable disk swap (partition kept for future re-enable)
  swapDevices = lib.mkForce [];

  # RAM compression (zram) as lightweight swap alternative
  zramSwap.enable = true;

  # Simagic force feedback wheel driver (Alpha EVO Pro)
  services.simagic-ff.enable = false;

  # LUKS tuning for NVMe SSDs
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/2029b089-eab2-4923-95ef-b94b757f5f74";
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true;

  # AMD CPU
  boot.kernelModules = [ "kvm-amd" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  hardware.cpu.amd.updateMicrocode = true;

  # ── WiFi Hotspot ──
  services.wifi-hotspot = {
    enable = false;
    ssid = "rhea-ap";
    passphraseFile = config.sops.secrets.wifi-passphrase.path;
    # wifiInterface = "wlan0";    # default
    # ethernetInterface = "enp7s0"; # default
    # subnetPrefix = "192.168.4";   # default → 192.168.4.0/24
  };

  # ── Networking ──
  networking.hostName = "rhea";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";  # Use iwd backend
  networking.wireless.enable = false;  # Disable wpa_supplicant
  # Disable WiFi by blacklisting common WiFi kernel modules
  boot.blacklistedKernelModules = [ "iwlwifi" "iwlmvm" "ath9k" "ath10k" "rtw88" "mt76" ];

  # ── ZeroTier ──
  services.zerotierone.enable = true;
  systemd.services.zerotierone = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  # ── Tailscale ──
  services.tailscale.enable = true;

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
    # Prevent the speaker node from being suspended between keep-speakers-alive plays.
    # suspend-node.lua explicitly checks session.suspend-timeout-seconds and skips
    # suspension when it is 0. The wireplumber.profiles approach (hooks.node.suspend = disabled)
    # does not reliably take effect via conf.d drop-ins in WirePlumber 0.5.x.
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-disable-suspension.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              { node.name = "alsa_output.pci-0000_74_00.6.analog-stereo" }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
    # Pin SoX (keep-speakers-alive) directly to the analog speaker sink,
    # bypassing EasyEffects so the tone doesn't follow the default sink.
    extraConfig.pipewire-pulse."52-sox-speaker-only" = {
      "pulse.rules" = [
        {
          matches = [ { "application.name" = "SoX"; } ];
          actions = {
            update-props = {
              "node.target" = "alsa_output.pci-0000_74_00.6.analog-stereo";
              "stream.dont-move" = true;
            };
          };
        }
      ];
    };
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

  # ── MTP (Meta Quest, Android file transfer) ──
  services.gvfs.enable = true;

  # ── Steam ──
  services.steam.enable = true;
  services.steam.protonGE = true;

  # ── Flatpak ──
  services.flatpak.enable = false;

  # ── Windows VM (raw disk passthrough from Patriot P400L NVMe) ──
  services.windows-vm.enable = true;

  # ── WoeUSB ──
  programs.woeusb.enable = true;

  programs.nix-ld.enable = true;

  # ── NCALayer ──
  programs.ncalayer = {
    enable = true;
    installCerts = true;
  };

  xdg.portal = {                                                                                                                                                                                                                                                                                                                                               
    enable = true;                                                                                                                                                                                                                                                                                                                                             
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];                                                                                                                                                                                                                                                                                                        
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
    openssl
    nvidia-vaapi-driver # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
