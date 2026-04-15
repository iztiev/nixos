{ config, pkgs, lib, ... }:
{
  options.services.v2ray-custom.extraConfigFiles = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [];
    description = "Additional v2ray JSON config files merged at startup (e.g. transparent proxy inbounds).";
  };

  config = {
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
            "loglevel": "info"
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
          "routing": {
            "domainStrategy": "IPIfNonMatch",
            "rules": [
              {
                "type": "field",
                "domain": [
                  "iztiev.dev",
                  "drive.iztiev.dev",
                  "vr.iztiev.dev",
                  "yandex.com",
                  "d-cd.net",
                  "kz",
                  "ru",
                  "youtube.com",
                  "youtu.be",
                  "ytimg.com",
                  "yt.be",
                  "googlevideo.com",
                  "youtube-nocookie.com",
                  "youtube-ui.l.google.com",
                  "youtubeembedded.com",
                  "youtubei.googleapis.com",
                  "yt3.ggpht.com",
                  "yt3.googleusercontent.com",
                  "vk.com",
                  "vkusercontent.com",
                  "vk.me",
                  "vkuseraudio.net",
                  "vkuservideo.net",
                  "userapi.com",
                  "vk-cdn.net",
                  "vk.cc",
                  "vkontakte.ru",
                  "google.com",
                  "google.ru",
                  "google.kz",
                  "googleapis.com",
                  "googleusercontent.com",
                  "gstatic.com",
                  "ggpht.com",
                  "google-analytics.com",
                  "googletagmanager.com",
                  "googlesyndication.com",
                  "googleadservices.com",
                  "doubleclick.net",
                  "gmail.com",
                  "gmail.googleapis.com",
                  "googlemail.com",
                  "google.com.kz",
                  "2gis.kz",
                  "2gis.com",
                  "2gis.ru"
                ],
                "outboundTag": "direct"
              },
              {
                "type": "field",
                "ip": [
                  "127.0.0.0/8",
                  "192.0.0.0/8",
                  "172.0.0.0/8",
                  "10.0.0.0/8"
                ],
                "outboundTag": "direct"
              },
              {
                "type": "field",
                "network": "tcp,udp",
                "outboundTag": "proxy"
              }
            ]
          },
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
                "network": "ws",
                "security": "tls",
                "tlsSettings": {
                  "serverName": "${config.sops.placeholder.vmess-address}"
                },
                "wsSettings": {
                  "path": "/ray"
                }
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
        ExecStart =
          let
            allConfigs = [ config.sops.templates."v2ray-config.json".path ]
              ++ config.services.v2ray-custom.extraConfigFiles;
            configArgs = lib.concatMapStringsSep " " (f: "-c ${f}") allConfigs;
          in
          "${pkgs.v2ray}/bin/v2ray run ${configArgs}";
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
  };
}
