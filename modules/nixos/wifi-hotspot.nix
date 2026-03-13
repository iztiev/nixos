{ config, pkgs, lib, ... }:

let
  cfg = config.services.wifi-hotspot;
  tproxyPort = 12345;

  # Transparent proxy inbound for v2ray — no secrets needed, just a plain file.
  # v2ray merges this with the main SOPS config at startup.
  tproxyConfig = pkgs.writeText "v2ray-tproxy.json" (builtins.toJSON {
    inbounds = [
      {
        port = tproxyPort;
        listen = "0.0.0.0";
        protocol = "dokodemo-door";
        settings = {
          network = "tcp";
          followRedirect = true;  # reads SO_ORIGINAL_DST from iptables REDIRECT
        };
        sniffing = {
          enabled = true;
          destOverride = [ "http" "tls" ];
        };
        tag = "tproxy-in";
      }
    ];
  });
in
{
  options.services.wifi-hotspot = {
    enable = lib.mkEnableOption "WiFi hotspot sharing ethernet via v2ray transparent proxy";

    ssid = lib.mkOption {
      type = lib.types.str;
      description = "SSID of the hotspot.";
    };

    # NOTE: passphrase is stored in the Nix store (world-readable).
    # For better security, use passphraseFile pointing to a sops secret instead.
    passphrase = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "WPA2 passphrase (ends up in Nix store — prefer passphraseFile).";
    };

    passphraseFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing the WPA2 passphrase (e.g. a sops secret).";
    };

    wifiInterface = lib.mkOption {
      type = lib.types.str;
      default = "wlan0";
      description = "WiFi interface to use as the access point.";
    };

    ethernetInterface = lib.mkOption {
      type = lib.types.str;
      default = "enp7s0";
      description = "Ethernet interface that provides internet.";
    };

    subnetPrefix = lib.mkOption {
      type = lib.types.str;
      default = "192.168.4";
      description = "First three octets of the AP subnet (e.g. 192.168.4 → 192.168.4.0/24).";
    };

    channel = lib.mkOption {
      type = lib.types.int;
      default = 36;
      description = "5 GHz channel for the AP (36, 40, 44, 48 are safe non-DFS channels).";
    };
  };

  config = lib.mkMerge [
    { sops.secrets.wifi-passphrase = { }; }
    (lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.passphrase != null || cfg.passphraseFile != null;
        message = "services.wifi-hotspot: set either passphrase or passphraseFile.";
      }
      {
        assertion = !(cfg.passphrase != null && cfg.passphraseFile != null);
        message = "services.wifi-hotspot: set only one of passphrase or passphraseFile, not both.";
      }
    ];

    # ── WiFi AP ──────────────────────────────────────────────────────────────

    # Tell NetworkManager to leave this interface alone so hostapd can own it.
    networking.networkmanager.unmanaged = [ "interface-name:${cfg.wifiInterface}" ];

    # Assign the static IP after hostapd brings the interface up.
    # (networking.interfaces would try before hostapd, when wlan0 is still DOWN.)
    systemd.services."hotspot-ip-${cfg.wifiInterface}" = {
      description = "Assign static IP to ${cfg.wifiInterface} AP interface";
      after = [ "hostapd.service" ];
      bindsTo = [ "hostapd.service" ];
      wantedBy = [ "hostapd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip addr replace ${cfg.subnetPrefix}.1/24 dev ${cfg.wifiInterface}";
        ExecStop  = "${pkgs.iproute2}/bin/ip addr del ${cfg.subnetPrefix}.1/24 dev ${cfg.wifiInterface} || true";
      };
    };

    # dnsmasq must start after the interface is up and has its IP.
    systemd.services.dnsmasq = {
      after    = [ "hotspot-ip-${cfg.wifiInterface}.service" ];
      requires = [ "hotspot-ip-${cfg.wifiInterface}.service" ];
    };

    services.hostapd = {
      enable = true;
      radios.${cfg.wifiInterface} = {
        countryCode = "KZ";
        band = "5g";
        channel = cfg.channel;
        wifi4.enable = false;
        wifi5.enable = true;  # 802.11ac — broad client compatibility
        wifi6.enable = false;
        networks.${cfg.wifiInterface} = {
          ssid = cfg.ssid;
          authentication = {
            mode = "wpa2-sha256";
          } // lib.optionalAttrs (cfg.passphrase != null) {
            wpaPassword = cfg.passphrase;
          } // lib.optionalAttrs (cfg.passphraseFile != null) {
            wpaPasswordFile = cfg.passphraseFile;
          };
        };
      };
    };

    # ── DHCP for hotspot clients ──────────────────────────────────────────────

    services.dnsmasq = {
      enable = true;
      # Don't redirect the host's own DNS through dnsmasq — it only listens on
      # the hotspot interface, so host DNS queries would get no answer.
      resolveLocalQueries = false;
      settings = {
        interface = cfg.wifiInterface;
        bind-interfaces = true;
        dhcp-range = [ "${cfg.subnetPrefix}.50,${cfg.subnetPrefix}.150,24h" ];
        # Give clients the gateway as router; use Cloudflare for DNS (not loopback,
        # so DNS queries bypass the proxy — simpler and avoids UDP tproxy complexity).
        dhcp-option = [
          "option:router,${cfg.subnetPrefix}.1"
          "option:dns-server,1.1.1.1,1.0.0.1"
        ];
      };
    };

    # Allow DHCP + DNS from the hotspot interface.
    networking.firewall.interfaces.${cfg.wifiInterface} = {
      allowedUDPPorts = [ 53 67 ];
      allowedTCPPorts = [ 53 ];
    };

    # ── Routing & NAT ─────────────────────────────────────────────────────────

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.firewall.extraCommands = ''
      # Accept all traffic arriving on the hotspot interface.
      iptables -A INPUT -i ${cfg.wifiInterface} -j ACCEPT

      # Allow forwarding between WiFi clients and the internet.
      iptables -A FORWARD -i ${cfg.wifiInterface} -o ${cfg.ethernetInterface} -j ACCEPT
      iptables -A FORWARD -i ${cfg.ethernetInterface} -o ${cfg.wifiInterface} \
        -m state --state RELATED,ESTABLISHED -j ACCEPT

      # Masquerade outgoing packets so WiFi clients appear as this machine.
      iptables -t nat -A POSTROUTING -o ${cfg.ethernetInterface} -j MASQUERADE

      # ── Transparent proxy (TCP only) ──────────────────────────────────────
      # Skip redirect for private/local destinations — let them go direct.
      iptables -t nat -A PREROUTING -i ${cfg.wifiInterface} -d 10.0.0.0/8     -p tcp -j RETURN
      iptables -t nat -A PREROUTING -i ${cfg.wifiInterface} -d 172.16.0.0/12  -p tcp -j RETURN
      iptables -t nat -A PREROUTING -i ${cfg.wifiInterface} -d 192.168.0.0/16 -p tcp -j RETURN
      # Redirect all remaining TCP from hotspot clients to v2ray tproxy port.
      iptables -t nat -A PREROUTING -i ${cfg.wifiInterface} -p tcp \
        -j REDIRECT --to-port ${toString tproxyPort}
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D INPUT -i ${cfg.wifiInterface} -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -i ${cfg.wifiInterface} -o ${cfg.ethernetInterface} -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -i ${cfg.ethernetInterface} -o ${cfg.wifiInterface} \
        -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
      iptables -t nat -D POSTROUTING -o ${cfg.ethernetInterface} -j MASQUERADE 2>/dev/null || true
      iptables -t nat -D PREROUTING -i ${cfg.wifiInterface} -d 10.0.0.0/8     -p tcp -j RETURN 2>/dev/null || true
      iptables -t nat -D PREROUTING -i ${cfg.wifiInterface} -d 172.16.0.0/12  -p tcp -j RETURN 2>/dev/null || true
      iptables -t nat -D PREROUTING -i ${cfg.wifiInterface} -d 192.168.0.0/16 -p tcp -j RETURN 2>/dev/null || true
      iptables -t nat -D PREROUTING -i ${cfg.wifiInterface} -p tcp \
        -j REDIRECT --to-port ${toString tproxyPort} 2>/dev/null || true
    '';

    # Unblock WiFi rfkill before hostapd starts (soft-blocked by default).
    systemd.services.hostapd = {
      path = [ pkgs.util-linux ];
      preStart = "rfkill unblock wifi";
    };

    # ── v2ray transparent proxy inbound ──────────────────────────────────────

    # Inject the dokodemo-door inbound; v2ray merges it with the main SOPS config.
    services.v2ray-custom.extraConfigFiles = [ tproxyConfig ];
  })
];
}
