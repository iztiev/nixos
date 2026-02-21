{ config, ... }:
{
  # Decrypt secrets using the machine's SSH host key (converted to age internally).
  # The age public key for .sops.yaml is derived from /etc/ssh/ssh_host_ed25519_key.pub —
  # see README for the one-time setup command.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  sops.secrets."iztiev/password" = {
    # neededForUsers makes sops decrypt this secret before user accounts are
    # configured, which is required for hashedPasswordFile to work.
    neededForUsers = true;
  };

  users.users.iztiev.hashedPasswordFile = config.sops.secrets."iztiev/password".path;
}
