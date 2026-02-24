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

  # ── Firefox with Declarative Extensions ──
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";

      Preferences = {
        # Privacy settings
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.pinned" = "";
        "browser.topsites.contile.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
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

        # Zoom settings
        "layout.css.devPixelsPerPx" = "1.0";
        "browser.zoom.siteSpecific" = true;  # Remember per-site zoom levels
        "browser.zoom.full" = true;          # Full page zoom (not text-only)
        "zoom.defaultPercent" = 150;
        "zoom.default" = 1.5;

        # Disable password saving and autofills
        "signon.rememberSignons" = false;    # Disable password manager
        "signon.autofillForms" = false;      # Disable autofill for login forms
        "browser.formfill.enable" = false;   # Disable form autofill
        "browser.aboutConfig.showWarning" = false;
        "browser.compactmode.show" = true;
      };
    };
  };

  # ── Git ──
  programs.git = {
    enable = true;
    userName = "Timur Izmagambetov";
    # user.email is set via sops template at ~/.config/git/config-email
    includes = [
      { path = "~/.config/git/config-email"; }
    ];
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── SSH ──
  # Directly manage SSH config file to ensure it's always created
  home.file.".ssh/config" = {
    force = true;
    text = ''
      Host github.com
        IdentityFile ~/.ssh/id_github
      Host gitlab.finq.kz
        IdentityFile ~/.ssh/id_github
      Host llm.sx
        IdentityFile ~/.ssh/id_dilcher
      Host 35.164.116.189
        IdentityFile ~/.ssh/id_dilcher
      Host 49.12.110.230
        IdentityFile ~/.ssh/id_dilcher
      Host 37.27.241.163
        IdentityFile ~/.ssh/id_dilcher
      Host *.backend.sx
        IdentityFile ~/.ssh/id_dilcher
      Host iztiev.dev
        IdentityFile ~/.ssh/id_hetzner
      Host *.iztiev.dev
        IdentityFile ~/.ssh/id_hetzner
      Host *.embeddings.sx
        IdentityFile ~/.ssh/id_dilcher
      Host *.liquid.mx
        IdentityFile ~/.ssh/id_dilcher
      Host *.devel.pm
        IdentityFile ~/.ssh/id_dilcher
      Host 138.201.206.85
        IdentityFile ~/.ssh/id_dilcher
      Host 195.201.164.162
        IdentityFile ~/.ssh/id_dilcher
      Host 37.27.141.78
        IdentityFile ~/.ssh/id_dilcher
      Host *.liquid.pm
        IdentityFile ~/.ssh/id_dilcher
      Host zt.moon.backend.sx
        IdentityFile ~/.ssh/id_dilcher
      Host 10.98.81.94
        IdentityFile ~/.ssh/id_dilcher
      Host 10.98.81.14
        IdentityFile ~/.ssh/id_dilcher
      Host *
        ServerAliveInterval 100
    '';
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

  # ── Disable SSH Agent ──
  # Prevents gcr-ssh-agent from starting and caching SSH keys
  # You will be prompted for your passphrase on every SSH use
  systemd.user.services.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
  };
  systemd.user.sockets.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
  };

  # ── Default Applications ──
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  # ── SSH Directory Permissions ──
  # Ensure ~/.ssh directory has correct permissions (700) for SSH to work properly
  # sops-nix creates this directory when placing SSH keys, but with incorrect permissions
  home.activation.fixSshPermissions = config.lib.dag.entryBefore ["writeBoundary"] ''
    if [ -d "$HOME/.ssh" ]; then
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"
      echo "Fixed ~/.ssh directory permissions to 700"
    fi
  '';

  # ── COSMIC Input Settings via Activation Script ──
  # COSMIC overwrites config files at runtime, breaking symlinks
  # So we use activation scripts to copy (not symlink) the settings on each rebuild
  home.activation.cosmicInputSettings = config.lib.dag.entryAfter ["writeBoundary"] ''
    INPUT_DEFAULT="$HOME/.config/cosmic/com.system76.CosmicComp/v1/input_default"
    mkdir -p "$(dirname "$INPUT_DEFAULT")"

    cat > "$INPUT_DEFAULT" <<'EOF'
(
    state: Enabled,
    scroll_config: Some((
        method: Some(TwoFinger),
        natural_scroll: Some(true),
    )),
    acceleration: Some((
        profile: Some(Flat),
        speed: 0.0,
    )),
)
EOF

    $DRY_RUN_CMD chmod 644 "$INPUT_DEFAULT"
    echo "Applied COSMIC input settings (natural scroll + flat acceleration)"
  '';

  # ── SSH Public Keys with Secret Emails ──
  # Build id_dilcher.pub using the email-work secret
  home.activation.sshDilcherPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-work ]; then
      EMAIL_WORK=$(cat /run/secrets/email-work)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzWSM7wSnAL65rJXZaDgcMo9ZmPKM1ZfhZaS9QF5GVD $EMAIL_WORK"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_dilcher.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_dilcher.pub"
      echo "Created id_dilcher.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-work not found, skipping id_dilcher.pub creation"
    fi
  '';

  # Build id_github.pub using the email-gmail secret
  home.activation.sshGithubPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-gmail ]; then
      EMAIL_GMAIL=$(cat /run/secrets/email-gmail)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFPV4++2NsKJGEs8q9U0CTQ0S1jYLW6nGU/0Xx5F8mC $EMAIL_GMAIL"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_github.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github.pub"
      echo "Created id_github.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-gmail not found, skipping id_github.pub creation"
    fi
  '';

  # Build id_iztiev.pub using the email-gmail secret
  home.activation.sshIztievPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-gmail ]; then
      EMAIL_GMAIL=$(cat /run/secrets/email-gmail)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/gHKm75N4OZmAWl/NjzNSGVJFlcN8nqMiElDQoTgzF $EMAIL_GMAIL"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_iztiev.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_iztiev.pub"
      echo "Created id_iztiev.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-gmail not found, skipping id_iztiev.pub creation"
    fi
  '';

  # Build id_hetzner.pub using the email-proton secret
  home.activation.sshHetznerPubKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f /run/secrets/email-proton ]; then
      EMAIL_PROTON=$(cat /run/secrets/email-proton)
      SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8c0Yv+V3h3wV5dH7dYp3Rp6IC6FwpUOEaU213jPxJ7 $EMAIL_PROTON"

      mkdir -p "$HOME/.ssh"
      echo "$SSH_PUB_KEY" > "$HOME/.ssh/id_hetzner.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_hetzner.pub"
      echo "Created id_hetzner.pub with email from sops secret"
    else
      echo "Warning: /run/secrets/email-proton not found, skipping id_hetzner.pub creation"
    fi
  '';

  home.stateVersion = "25.11";
}
