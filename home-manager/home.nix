{ config, pkgs, inputs, ... }:
{
  imports = [
    ../modules/home-manager
  ];

  home.username = "iztiev";
  home.homeDirectory = "/home/iztiev";

  # ── Environment Variables ──
  home.sessionVariables = {
    # EDITOR = "nano";
    # VISUAL = "code";
    # Fix cursor size in XWayland apps (PyCharm, WebStorm, etc.)
    XCURSOR_SIZE = "24";  # Standard cursor size (24 or 32 typical)
    # Disable SSH agent to prevent key caching
    SSH_AUTH_SOCK = "";
  };

  # ── Directory Structure ──
  # Ensure Projects directory structure exists
  home.file."Projects/github/.keep".text = "";
  home.file."Projects/local/.keep".text = "";

  # ── SSH Public Keys ──
  # Note: All SSH public keys use sops secrets for email addresses
  # They are created via activation scripts below

  # ── User Packages ──
  home.packages = with pkgs; [
    # Utilities
    htop
    ripgrep
    fd
    unzip

    # Internet
    remmina
    chromium
    qbittorrent
    postman
    keystore-explorer
    bitwarden-desktop
    slack
    telegram-desktop
    discord
    filezilla

    # networking
    traceroute
    dnsutils

    # Ofiice
    libreoffice-qt

    # Sound
    sox
    easyeffects
    yandex-music

    # Media
    yt-dlp
  ];

  # ── Shell ──
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      rebuild-home = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      update = "nix flake update --flake ~/nixos";
      cleanup = "sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && nix-env --delete-generations +2 && sudo nix-collect-garbage -d && before=$(du -sb /nix/store | cut -f1) && sudo nix store optimise && after=$(du -sb /nix/store | cut -f1) && saved=$((before-after)) && echo Optimise freed: $(numfmt --to=iec-i --suffix=B $saved)";
      windows = "sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY windows-vm";
      ytd = "yt-dlp --cookies-from-browser firefox -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4";
    };
    initExtra = ''
      rhea-ap() {
        case "$1" in
          start)   sudo nmcli device set wlan0 managed no  && sudo systemctl start hostapd.service ;;
          stop)    sudo systemctl stop hostapd.service     && sudo nmcli device set wlan0 managed yes ;;
          restart) sudo nmcli device set wlan0 managed no  && sudo systemctl restart hostapd.service ;;
          *)       echo "Usage: rhea-ap {start|stop|restart}" ;;
        esac
      }
    '';
  };

  # ── Keep Speakers Alive ──
  # Play inaudible white noise every 9 minutes to prevent speakers from sleeping
  systemd.user.services.keep-speakers-alive = {
    Unit.Description = "Play white noise to keep speakers alive";
    Service = {
      Type = "oneshot";
      Environment = "PULSE_SINK=alsa_output.pci-0000_74_00.6.analog-stereo";
      ExecStart = "${pkgs.sox}/bin/play -n -c1 synth 5 whitenoise band -n 19000 20 fade h 1 3 1 vol 0.2";
    };
  };

  systemd.user.timers.keep-speakers-alive = {
    Unit.Description = "Keep speakers alive timer";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "4min";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.stateVersion = "25.11";
}
