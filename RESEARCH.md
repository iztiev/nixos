# System-Wide V2Ray VMess Proxy on NixOS

Currently V2Ray runs as a SOCKS5 proxy on port 1080. This document researches all viable approaches to route **all** system traffic through it.

---

## 1. V2Ray/Xray Built-in Transparent Proxy (TPROXY) with dokodemo-door

**Mechanism:** V2Ray natively supports transparent proxying via `dokodemo-door` inbound + Linux kernel TPROXY target. iptables/nftables intercept all outgoing TCP/UDP traffic and redirect it to a local dokodemo-door port with `"followRedirect": true` and `"tproxy": "tproxy"`. V2Ray reads the original destination and forwards through VMess. Loop prevention via packet marking (SO_MARK/fwmark).

- **TCP/UDP:** Both supported. UDP requires policy routing (`ip rule add fwmark 1 lookup 100`).
- **DNS leak prevention:** Excellent -- intercept port 53 + built-in DNS module + SNI/Host sniffing.
- **NixOS module:** `services.v2ray` / `services.xray` available. **v2rayA** (`services.v2raya`) provides a web GUI that automates iptables rules, but has a [known nftables detection bug](https://github.com/NixOS/nixpkgs/issues/294091).
- **V2Ray config changes:** Yes -- substantial (dokodemo-door inbound, DNS routing, packet marking).
- **Complexity:** **High.** Requires deep iptables/nftables TPROXY + policy routing knowledge. Fragile rules can break Docker/VMs.

**Sources:**
- [Transparent Proxy (TProxy) Tutorial - Project X](https://xtls.github.io/en/document/level-2/tproxy.html)
- [V2Ray Transparent Proxy Guide](https://guide.v2fly.org/en_US/app/transparent_proxy.html)

---

## 2. tun2socks -- TUN Interface Forwarding to SOCKS5

**Mechanism:** Creates a virtual TUN device (`tun0`), captures all traffic routed through it, wraps each connection into SOCKS5, and forwards to localhost:1080. Routing is modified so default traffic goes through TUN while proxy traffic goes through the real interface.

```bash
ip tuntap add mode tun dev tun0
ip addr add 198.18.0.1/15 dev tun0
ip link set dev tun0 up
ip route add default via 198.18.0.1 dev tun0 metric 1
ip route add default via <real-gateway> dev <real-interface> metric 10
tun2socks -device tun0 -proxy socks5://127.0.0.1:1080 -interface <real-interface>
```

- **TCP/UDP:** Both supported (Go implementation: xjasonlyu/tun2socks).
- **DNS leak prevention:** Moderate -- DNS goes through TUN but no sniffing/hijacking.
- **NixOS module:** **Not in nixpkgs.** Requires custom packaging.
- **V2Ray config changes:** **None** -- works with existing SOCKS5 proxy as-is.
- **Complexity:** **Medium.** Needs systemd service for TUN + routing, custom packaging.

**Sources:**
- [tun2socks GitHub](https://github.com/xjasonlyu/tun2socks)
- [tun2socks Route Configuration](https://github.com/xjasonlyu/tun2socks/wiki/Route-Configuration)

---

## 3. sing-box -- Modern Universal Proxy with Built-in TUN Mode (Recommended)

**Mechanism:** Single binary handles both proxy protocol (VMess) and transparent proxy (TUN). On Linux, uses nftables `auto_redirect` under the hood. Replaces V2Ray entirely.

```nix
services.sing-box = {
  enable = true;
  settings = {
    inbounds = [{
      type = "tun";
      interface_name = "tun0";
      address = [ "172.16.0.1/30" "fd00::1/126" ];
      auto_route = true;
      auto_redirect = true;
      strict_route = true;
      sniff = true;
    }];
    outbounds = [
      {
        type = "vmess";
        tag = "proxy";
        server = "YOUR_SERVER";
        server_port = 443;
        uuid = "YOUR_UUID";
        security = "auto";
        transport = { type = "ws"; path = "/ray"; };
        tls = { enabled = true; server_name = "YOUR_SERVER"; };
      }
      { type = "direct"; tag = "direct"; }
      { type = "dns"; tag = "dns-out"; }
    ];
    route = {
      auto_detect_interface = true;
      rules = [
        { protocol = "dns"; outbound = "dns-out"; }
        { ip_is_private = true; outbound = "direct"; }
      ];
    };
  };
};
networking.firewall.trustedInterfaces = [ "tun0" ];
```

- **TCP/UDP:** Both fully supported.
- **DNS leak prevention:** Excellent -- built-in DNS hijacking, sniffing, FakeDNS.
- **NixOS module:** `services.sing-box` in nixpkgs.
- **V2Ray config changes:** **Replaces V2Ray** -- sing-box natively speaks VMess.
- **Complexity:** **Low-Medium.** Single JSON config, no manual iptables rules.

**Sources:**
- [sing-box TUN docs](https://sing-box.sagernet.org/configuration/inbound/tun/)
- [NixOS Discourse: sing-box TUN setup](https://discourse.nixos.org/t/sing-box-tun-inbound-in-client-configuration-did-not-work-for-http-s-traffics/57552)

---

## 4. redsocks -- Transparent TCP Redirect to SOCKS Proxy

**Mechanism:** Listens on a local port, accepts iptables NAT REDIRECT'd connections, reads original destination via `SO_ORIGINAL_DST`, and forwards through SOCKS5.

```nix
services.redsocks = {
  redsocks = [{
    port = 12345;
    proxy = "127.0.0.1:1080";
    type = "socks5";
  }];
};
```

- **TCP/UDP:** **TCP only.** Major limitation -- no UDP support.
- **DNS leak prevention:** Poor.
- **NixOS module:** `services.redsocks` available.
- **V2Ray config changes:** None.
- **Complexity:** **Low,** but still needs iptables REDIRECT rules.

**Sources:**
- [redsocks GitHub](https://github.com/darkk/redsocks)

---

## 5. cgproxy / cgroup-based Routing

**Mechanism:** Uses cgroup v2 to classify processes, applies iptables TPROXY rules per-cgroup. Allows per-application proxy control.

- **TCP/UDP:** Both supported (via TPROXY).
- **DNS leak prevention:** Good.
- **NixOS module:** **Not in nixpkgs.** Requires custom packaging + V2Ray dokodemo-door config.
- **V2Ray config changes:** Yes (dokodemo-door TPROXY inbound).
- **Complexity:** **High.**

**Sources:**
- [cgproxy GitHub](https://github.com/springzfx/cgproxy)

---

## 6. Environment Variables (`networking.proxy`)

```nix
networking.proxy = {
  default = "socks5://127.0.0.1:1080";
  noProxy = "127.0.0.1,localhost,::1";
};
```

- **TCP/UDP:** HTTP/HTTPS TCP only. Most apps ignore these variables.
- **DNS leak prevention:** None.
- **V2Ray config changes:** None.
- **Complexity:** Trivial -- but **not system-wide at all.** Only works for apps that honor proxy env vars. GUI apps, systemd services, games, etc. ignore them.

---

## 7. dae/daed -- eBPF-Based Transparent Proxy (Best Performance)

**Mechanism:** Uses eBPF to intercept traffic directly in the kernel, before it reaches the network stack. No iptables/nftables needed. Successor to v2rayA.

```nix
services.dae = {
  enable = true;
  openFirewall.enable = true;
};
```

- **TCP/UDP:** Both fully supported.
- **DNS leak prevention:** Excellent.
- **NixOS module:** `services.dae` in nixpkgs. Also has a [dedicated flake](https://github.com/daeuniverse/flake.nix).
- **V2Ray config changes:** **Replaces V2Ray.** Supports VMess natively.
- **Complexity:** **Low.** But newer project, unique config format.

**Sources:**
- [dae GitHub](https://github.com/daeuniverse/dae)
- [dae NixOS flake](https://github.com/daeuniverse/flake.nix)

---

## 8. Mihomo (Clash Meta) -- TUN Mode

**Mechanism:** Creates a TUN interface, captures all system traffic. Supports VMess and many other protocols.

```nix
services.mihomo = {
  enable = true;
  configFile = "/path/to/config.yaml";
};
networking.firewall.trustedInterfaces = [ "Mihomo" ];
networking.firewall.checkReversePath = false;
```

- **TCP/UDP:** Both supported.
- **DNS leak prevention:** Good.
- **NixOS module:** `services.mihomo` available.
- **V2Ray config changes:** Replaces V2Ray.
- **Complexity:** Low-Medium. [Known nftables reverse path filtering issue](https://github.com/nixos/nixpkgs/issues/477636).

---

## Comparison Matrix

| Approach | TCP | UDP | DNS Leak Prevention | NixOS Module | Replaces V2Ray | Complexity | Performance |
|---|---|---|---|---|---|---|---|
| V2Ray TPROXY | Yes | Yes | Excellent | `services.v2ray` | No (modifies config) | High | Good |
| tun2socks | Yes | Yes | Moderate | No | No | Medium | Moderate |
| **sing-box TUN** | **Yes** | **Yes** | **Excellent** | **`services.sing-box`** | **Yes** | **Low-Med** | **Very Good** |
| redsocks | Yes | **No** | Poor | `services.redsocks` | No | Low | Good |
| cgproxy | Yes | Yes | Good | No | No (modifies config) | High | Good |
| Env Variables | HTTP only | No | None | `networking.proxy` | No | Trivial | N/A |
| **dae (eBPF)** | **Yes** | **Yes** | **Excellent** | **`services.dae`** | **Yes** | **Low** | **Best** |
| Mihomo/Clash | Yes | Yes | Good | `services.mihomo` | Yes | Low-Med | Good |

---

## Recommendations

### 1. sing-box with TUN mode (Best Balance)
- Replaces V2Ray but natively speaks VMess + WebSocket + TLS.
- In nixpkgs with `services.sing-box` module.
- `auto_redirect` handles all routing automatically -- no manual iptables.
- Single JSON config. Documented working on NixOS.

### 2. dae (Best Performance)
- eBPF-based, highest performance, no iptables needed.
- In nixpkgs with `services.dae` + dedicated flake.
- Replaces V2Ray, supports VMess natively.
- Newer project but very actively developed.

### 3. tun2socks (Least Invasive)
- **Only option that keeps V2Ray unchanged.**
- Works with existing SOCKS5 proxy on port 1080.
- Requires custom NixOS packaging.
- Good if you don't want to replace V2Ray.
