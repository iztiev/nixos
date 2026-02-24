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
    # Development
    claude-code

    # Utilities
    htop
    ripgrep
    fd
    unzip

    # Internet
    chromium
    qbittorrent

    # Ofiice
    libreoffice-qt
  ];

  # ── Git ──
  programs.git = {
    enable = true;
    # user.email is set via sops template at ~/.config/git/config-email
    includes = [
      { path = "~/.config/git/config-email"; }
    ];
    settings = {
      user.name = "Timur Izmagambetov";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── Shell ──
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      rebuild-home = "sudo nixos-rebuild switch --flake ~/nixos#rhea";
      update = "nix flake update --flake ~/nixos";
      cleanup = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && nix-env --delete-generations +3 && sudo nix-collect-garbage -d";
    };
  };

  home.stateVersion = "25.11";
}
