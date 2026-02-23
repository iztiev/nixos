{ config, pkgs, ... }:
{
  # Install v2ray package
  environment.systemPackages = with pkgs; [ v2ray ];

  # Declare VMess secrets
  sops.secrets = {
    vmess-address = { };
    vmess-port = { };
    vmess-id = { };
    vmess-email = { };
  };

  # Create V2Ray config with SOPS secret
  sops.templates."v2ray-config.json" = {
    owner = "v2ray";
    group = "v2ray";
    mode = "0440";
    content = ''
      {
        "log": {
          "loglevel": "warning"
        },
        "inbounds": [
          {
            "listen": "0.0.0.0",
            "port": 1080,
            "protocol": "socks",
            "settings": {
              "auth": "noauth",
              "udp": true,
              "ip": "127.0.0.1"
            }
          }
        ],
        "outbounds": [
          {
            "protocol": "vmess",
            "settings": {
              "vnext": [
                {
                  "address": "${config.sops.placeholder.vmess-address}",
                  "port": ${config.sops.placeholder.vmess-port},
                  "users": [
                    {
                      "id": "${config.sops.placeholder.vmess-id}",
                      "level": 0,
                      "email": "${config.sops.placeholder.vmess-email}"
                    }
                  ]
                }
              ]
            },
            "streamSettings": {
              "network": "tcp"
            },
            "tag": "proxy"
          },
          {
            "protocol": "freedom",
            "tag": "direct"
          }
        ]
      }
    '';
  };

  # Create v2ray user and group
  users.users.v2ray = {
    isSystemUser = true;
    group = "v2ray";
  };
  users.groups.v2ray = { };

  # Custom systemd service
  systemd.services.v2ray-vmess = {
    description = "V2Ray VMess Proxy";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "v2ray";
      Group = "v2ray";
      ExecStart = "${pkgs.v2ray}/bin/v2ray run -c ${config.sops.templates."v2ray-config.json".path}";
      Restart = "on-failure";
      RestartSec = "5s";

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  # Open firewall for SOCKS proxy
  networking.firewall.allowedTCPPorts = [ 1080 ];
}
