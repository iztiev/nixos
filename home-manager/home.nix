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
    chromium
    qbittorrent
    postman
    bitwarden-desktop
    slack
    telegram-desktop
    discord
    stoat-desktop

    # networking
    traceroute

    # Ofiice
    libreoffice-qt

    # Sound
    easyeffects
    yandex-music
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
    };
  };

  # ── Keep Microlab Solo 3 speakers awake ──
  # The Solo 3 has an auto-standby that cuts power after detecting silence.
  # Playing white noise at 0.1% volume keeps the DAC active
  # without a perceptible tone.
  systemd.user.services.keep-speakers-alive = {
    Unit = {
      Description = "Prevent Microlab Solo 3 auto-shutoff";
      After = "pipewire.service";
    };
    Service = {
      Environment = "PULSE_SINK=alsa_output.pci-0000_74_00.6.analog-stereo";
      ExecStart = "${pkgs.sox}/bin/play -n synth whitenoise vol 0.0001";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.stateVersion = "25.11";
}
