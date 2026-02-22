{ config, pkgs, lib, ... }:

with lib;

{
  options.services.docker-custom = {
    enable = mkEnableOption "Docker container runtime with rootless mode";

    useNvidiaGpu = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support for Docker containers";
    };

    autoPrune = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically prune unused Docker resources";
    };
  };

  config = mkIf config.services.docker-custom.enable {
    # ── Docker Rootless Configuration ──
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true; # Automatically set DOCKER_HOST for rootless socket
      };

      # Automatic cleanup of unused resources
      autoPrune = mkIf config.services.docker-custom.autoPrune {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };

      # Daemon settings
      daemon.settings = {
        # Use overlay2 storage driver (modern and efficient)
        storage-driver = "overlay2";

        # Enable experimental features for newer functionality
        experimental = true;

        # Log driver configuration
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };

    # ── NVIDIA Container Toolkit ──
    # Enable GPU support for containers (replaces deprecated enableNvidia option)
    hardware.nvidia-container-toolkit.enable = config.services.docker-custom.useNvidiaGpu;

    # ── Additional Docker Tools ──
    environment.systemPackages = with pkgs; [
      docker-compose  # Multi-container orchestration
      dive           # Analyze Docker image layers
      ctop           # Container metrics viewer
    ];

    # ── Rootless Prerequisites ──
    # Ensure subuid/subgid ranges are configured for rootless operation
    # NixOS handles this automatically when rootless is enabled, but we
    # explicitly document the requirements here for clarity

    # Each user running rootless Docker needs entries in /etc/subuid and /etc/subgid
    # Format: username:100000:65536 (user gets UIDs/GIDs 100000-165535)
    # These are automatically created by NixOS when rootless.enable = true

    # ── Environment Variables ──
    environment.sessionVariables = mkIf config.services.docker-custom.useNvidiaGpu {
      # Ensure NVIDIA runtime is available to containers
      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "compute,utility,graphics";
    };

    # ── Firewall Configuration ──
    # Docker creates its own iptables rules for container networking
    # Ensure the firewall doesn't interfere with container-to-container communication
    networking.firewall.trustedInterfaces = [ "docker0" ];
  };
}
