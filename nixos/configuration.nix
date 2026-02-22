{ config, pkgs, lib, ... }:
{
  # ── Nix Settings ──
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Boot ──
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
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
  networking.networkmanager.wifi.backend = "iwd";  # Use iwd backend
  networking.wireless.enable = false;  # Disable wpa_supplicant
  # Disable WiFi by blacklisting common WiFi kernel modules
  boot.blacklistedKernelModules = [ "iwlwifi" "iwlmvm" "ath9k" "ath10k" "rtw88" "mt76" ];

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

  # ── Desktop Environment ──
  # Choose one: KDE Plasma 6 or COSMIC

  # KDE Plasma 6 (disabled)
  # services.kde = {
  #   enable = true;
  #   autoLogin = {
  #     enable = true;
  #     user = "iztiev";
  #   };
  # };

  # COSMIC Desktop
  services.cosmic = {
    enable = true;
    # autoLogin = {
    #   enable = true;
    #   user = "iztiev";
    # };
  };

  # ── Steam ──
  services.steam.enable = true;

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
    nvidia-vaapi-driver # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
