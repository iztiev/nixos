{ config, ... }:
{
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

  # ── Disable SSH Agent ──
  # Prevents gcr-ssh-agent from starting and caching SSH keys
  # You will be prompted for your passphrase on every SSH use
  systemd.user.services.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
  };
  systemd.user.sockets.gcr-ssh-agent = {
    Unit.RefuseManualStart = true;
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
}
