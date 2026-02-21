{ config, pkgs, inputs, ... }:
{
  home.username = "iztiev";
  home.homeDirectory = "/home/iztiev";

  # ── User Packages ──
  home.packages = with pkgs; [
    # Browsers
    chromium

    # Development
    claude-code
    jetbrains.pycharm
    jetbrains.webstorm

    # Utilities
    htop
    ripgrep
    fd
    unzip
  ];

  # ── Firefox with Declarative Extensions ──
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
#        styl-us
      ];
      settings = {
        "browser.contentblocking.category" = "strict";
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;
      };
    };
  };

  # ── Git ──
  programs.git = {
    enable = true;
    settings = {
      user.name = "Timur Izmagambetov";
      user.email = "iztiev@gmail.com";
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
      update = "nix flake update --flake ~/nixos";
    };
  };

  home.stateVersion = "25.11";
}
