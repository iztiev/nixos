# Installing NixOS 25.11 with NVIDIA, Secure Boot, and full encryption

**NixOS 25.11 "Xantusia" supports every component in this stack** — LUKS2 full disk encryption, Secure Boot via lanzaboote v1.0.0, proprietary NVIDIA drivers with Wayland, KDE Plasma 6, and a fully declarative flakes-based configuration with Home Manager. This guide provides the exact commands and complete configuration files to go from a blank NVMe drive to a fully working desktop system. The entire system is reproducible from a single Git repository.

NixOS 25.11 shipped November 30, 2025 with Linux 6.12, the new `nixos-rebuild-ng` default, and 7,002 new packages. Lanzaboote reached v1.0.0 in December 2025, making Secure Boot on NixOS production-ready. NVIDIA's open kernel modules are now recommended for all RTX 40-series GPUs, and KDE Plasma 6 defaults to Wayland — meaning this entire stack works without fighting the system.

---

## Phase 1: Booting the installer and preparing disks

Download the NixOS 25.11 minimal ISO from **https://nixos.org/download/** (the CLI "Minimal ISO" is recommended for manual installs). Flash it to USB with `dd` or a tool like Ventoy, then boot in **UEFI mode**. Disable Secure Boot temporarily in your BIOS — you will enable it later after lanzaboote is configured.

Once booted into the installer, switch to root and optionally connect to WiFi:

```bash
sudo -i
# For WiFi (skip if using ethernet):
systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourSSID"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

### Partitioning the NVMe drive

Create a **GPT partition table** with two partitions — a 1 GB EFI System Partition and the rest for LUKS encryption. The ESP is intentionally large because lanzaboote stores signed EFI images for every NixOS generation:

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1024MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 1024MiB 100%
```

### Setting up LUKS2 encryption with LVM

With systemd-boot (and later lanzaboote), you can use **LUKS2** — the LUKS1 limitation only applies to GRUB. Create the encrypted container, then set up LVM inside it for a clean separation of swap and root:

```bash
# Create LUKS2 encrypted partition (you'll set your passphrase here)
cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot

# Create LVM structure inside LUKS
pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 16G -n swap vg       # 16GB swap (adjust to RAM size for hibernation)
lvcreate -l 100%FREE -n root vg  # Remaining space for root

# Format filesystems
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/vg/root
mkswap -L swap /dev/vg/swap
```

### Mounting and generating initial configuration

```bash
mount /dev/vg/root /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/vg/swap

# Generate hardware detection config
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/configuration.nix` and `/mnt/etc/nixos/hardware-configuration.nix`. The generator automatically detects your LUKS device and adds the correct `boot.initrd.luks.devices` entry with the right UUID. Verify this:

```bash
cat /mnt/etc/nixos/hardware-configuration.nix | grep -A2 luks
```

You should see something like `boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/xxxx...";`.

### Minimal initial install

For the first boot, use a minimal `configuration.nix` — you'll convert to flakes immediately after. Edit `/mnt/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LUKS performance tuning for NVMe SSDs
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [ vim git ];

  system.stateVersion = "25.11";
}
```

Install and reboot:

```bash
nixos-install
reboot
```

You'll be prompted for the LUKS passphrase on boot, then log in and change your password with `passwd`.

---

## Phase 2: Converting to a flakes-based modular configuration

After your first successful boot, log in and create the flake-based configuration structure. This is where the real NixOS power begins. Create a clean directory structure:

```bash
sudo mkdir -p /etc/nixos
cd /etc/nixos
```

The recommended file layout:

```
/etc/nixos/
├── flake.nix                    # Entry point — all inputs and system definition
├── flake.lock                   # Auto-generated lockfile
├── hardware-configuration.nix   # Auto-generated (keep as-is)
├── configuration.nix            # System-level NixOS config
├── nvidia.nix                   # NVIDIA driver module
├── desktop.nix                  # KDE Plasma + SDDM module
├── secure-boot.nix              # Lanzaboote module
└── home.nix                     # Home Manager user config
```

### The master flake.nix

This file wires together all inputs — nixpkgs, Home Manager, lanzaboote, nix-flatpak, and the Firefox addons repository:

```nix
{
  description = "NixOS 25.11 — RTX 4080 Super, Secure Boot, KDE Plasma Wayland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, lanzaboote, nix-flatpak, firefox-addons, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        ./nvidia.nix
        ./desktop.nix
        ./secure-boot.nix

        lanzaboote.nixosModules.lanzaboote
        nix-flatpak.nixosModules.nix-flatpak

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.youruser = import ./home.nix;
        }
      ];
    };
  };
}
```

Key design decisions: `inputs.nixpkgs.follows = "nixpkgs"` on every input keeps the entire closure using a single nixpkgs, reducing evaluation time and closure size. The `specialArgs` line passes `inputs` to all NixOS modules, and `extraSpecialArgs` does the same for Home Manager modules — this is how `home.nix` accesses the Firefox addons input.

---

## Phase 3: System configuration modules

### configuration.nix — core system settings

```nix
{ config, pkgs, lib, ... }:
{
  # ── Nix Settings ──
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Boot ──
  boot.loader.efi.canTouchEfiVariables = true;
  # systemd-boot is disabled by secure-boot.nix (lanzaboote replaces it)
  # but we set it here so initial builds work before lanzaboote is active:
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.editor = false;

  # LUKS tuning
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true;

  # AMD CPU
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = true;

  # ── Networking ──
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ── Locale & Time ──
  time.timeZone = "America/New_York";  # Change to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Audio (PipeWire — required for Wayland screen sharing) ──
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Flatpak ──
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "com.slack.Slack"
    "org.telegram.desktop"
  ];
  services.flatpak.update.onActivation = true;

  # ── Electron/Chromium Wayland support ──
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Users ──
  users.users.youruser = {
    isNormalUser = true;
    description = "Your Name";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # ── System Packages ──
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    sbctl           # Secure Boot key management
    nvidia-vaapi-driver  # Hardware video acceleration
  ];

  system.stateVersion = "25.11";
}
```

### nvidia.nix — NVIDIA RTX 4080 Super with Wayland

The RTX 4080 Super uses the Ada Lovelace architecture. NVIDIA recommends the **open kernel modules** for all Turing (RTX 20) and newer GPUs. The `hardware.graphics` option replaced `hardware.opengl` starting in NixOS 24.11:

```nix
{ config, pkgs, lib, ... }:
{
  # ── GPU: NVIDIA RTX 4080 Super ──
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For Steam, Wine, 32-bit OpenGL apps
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is REQUIRED for Wayland compositors
    modesetting.enable = true;

    # Open-source kernel module — recommended for RTX 40 series (Ada Lovelace)
    # Only the kernel module is open; userspace libraries remain proprietary
    open = true;

    # Power management (disable for desktops; only useful for laptops)
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Driver branch: stable (default), beta, or production
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ── Wayland + NVIDIA environment variables ──
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
```

**No separate kernel module signing is needed for Secure Boot.** Lanzaboote signs the entire boot chain (bootloader, kernel, initrd hash). NVIDIA modules load after the kernel boots, from the already-trusted Nix store — unlike traditional distros, NixOS does not use DKMS, so no MOK enrollment is required.

### desktop.nix — KDE Plasma 6 on Wayland with SDDM

Plasma 6 defaults to a Wayland session. The option paths moved out from under `services.xserver` in NixOS 24.11+:

```nix
{ config, pkgs, lib, ... }:
{
  # ── Desktop Environment: KDE Plasma 6 ──
  services.desktopManager.plasma6.enable = true;

  # ── Display Manager: SDDM (Wayland) ──
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Run SDDM itself on Wayland
  };

  # Plasma 6 defaults to Wayland — explicit override only if needed:
  # services.displayManager.defaultSession = "plasma";

  # ── Optional: exclude unwanted default KDE packages ──
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa           # Music player
    kwrited         # Wall message daemon
  ];

  # ── Helpful KDE extras ──
  environment.systemPackages = with pkgs.kdePackages; [
    sddm-kcm          # SDDM settings in System Settings
    partitionmanager   # KDE Partition Manager
  ];
}
```

### secure-boot.nix — Lanzaboote Secure Boot

This module is initially commented out — you'll activate it after generating Secure Boot keys:

```nix
{ config, pkgs, lib, ... }:
{
  # ── Secure Boot via Lanzaboote ──
  # Lanzaboote replaces systemd-boot — MUST disable it
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
```

---

## Phase 4: Home Manager user configuration

### home.nix — declarative user environment

This file manages your user-level packages, Firefox with extensions, and program configurations:

```nix
{ config, pkgs, inputs, ... }:
{
  home.username = "youruser";
  home.homeDirectory = "/home/youruser";

  # ── User Packages ──
  home.packages = with pkgs; [
    # Browsers
    chromium

    # Development
    claude-code
    jetbrains.pycharm     # Professional edition (unfree)
    jetbrains.webstorm    # Unfree

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
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        styl-us        # Note: package name is "styl-us", not "stylus"
      ];
      settings = {
        # Privacy & performance defaults
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
    userName = "Your Name";
    userEmail = "you@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── Shell ──
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      update = "nix flake update --flake /etc/nixos";
    };
  };

  home.stateVersion = "25.11";
}
```

**Important notes on package names:** The JetBrains `pycharm-professional` was renamed to simply `jetbrains.pycharm` in 2025 — the old name still works as a deprecated alias but will emit warnings. The Firefox extension `styl-us` matches the AMO slug; searching for "stylus" in the rycee NUR won't find it. **Claude Code** is available directly from nixpkgs as `claude-code` — no npm workaround needed.

---

## Phase 5: Building the system and enabling Secure Boot

### First flake build

With all files in place, build and switch to the new configuration. On this first build, leave `secure-boot.nix` out of `flake.nix`'s modules list (or keep lanzaboote disabled) because you haven't generated keys yet:

```bash
cd /etc/nixos
# Comment out ./secure-boot.nix and the lanzaboote module in flake.nix temporarily
sudo nixos-rebuild switch --flake .#nixos
```

### Generating Secure Boot keys

After a successful build with systemd-boot still active:

```bash
# Generate Secure Boot signing keys
sudo nix run nixpkgs#sbctl create-keys
```

Keys are created in `/var/lib/sbctl/keys/`. Now uncomment the `./secure-boot.nix` module and the `lanzaboote.nixosModules.lanzaboote` line in `flake.nix`, then rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Verify all boot files are signed:

```bash
sudo sbctl verify
```

You should see checkmarks (✓) next to `/boot/EFI/BOOT/BOOTX64.EFI`, generation `.efi` files, and `systemd-bootx64.efi`. Unsigned kernel images under `/boot/EFI/nixos/` are **expected** — lanzaboote validates those itself via its stub.

### Enrolling keys in UEFI firmware

This is the critical step. The process varies by motherboard manufacturer:

1. **Reboot into UEFI/BIOS** (press DEL or F2 during POST)
2. **Navigate to Secure Boot settings** → enter **Setup Mode** by clearing all existing keys
3. **Save and exit** — boot back into NixOS
4. **Enroll your keys:**

```bash
# Enroll YOUR keys + Microsoft's keys (recommended for hardware compatibility)
sudo sbctl enroll-keys --microsoft
```

The `--microsoft` flag is strongly recommended — omitting it can brick systems that rely on Microsoft-signed Option ROMs (common in dedicated GPUs and some NVMe controllers). The RTX 4080 Super's VBIOS may require this.

5. **Reboot and verify:**

```bash
# Should show "Secure Boot: enabled (user)"
sudo bootctl status

# Should show Setup Mode: Disabled, Secure Boot: Enabled
sudo sbctl status
```

**Your system now boots with Secure Boot enabled**, LUKS full disk encryption, and signed NixOS generations. Each `nixos-rebuild switch` automatically signs new generations.

---

## Phase 6: Post-install Flatpak and final touches

### Flatpak apps install automatically

The `nix-flatpak` module in `configuration.nix` declaratively installs Bitwarden, Slack, and Telegram Desktop from Flathub on every system activation. After your first rebuild, these apps appear in the KDE application launcher. The module also adds the Flathub remote automatically — no manual `flatpak remote-add` needed.

If you ever want to pin specific Flatpak versions or set per-app overrides:

```nix
services.flatpak.overrides = {
  "com.slack.Slack" = {
    Environment.NIXOS_OZONE_WL = "1";  # Force Wayland for Slack
  };
};
```

### Verifying the full stack

After the final rebuild with all modules active, confirm everything works:

```bash
# Check NVIDIA driver is loaded
nvidia-smi

# Check Wayland session
echo $XDG_SESSION_TYPE    # Should print "wayland"

# Check Secure Boot
sudo bootctl status       # Secure Boot: enabled

# Check LUKS
lsblk                     # Should show cryptroot LUKS device

# Check Flatpak apps
flatpak list              # Should show Bitwarden, Slack, Telegram

# Check Claude Code
claude --version
```

---

## Complete file reference and rebuild workflow

Your daily workflow for system changes is straightforward:

```bash
# Edit configuration
sudo vim /etc/nixos/configuration.nix  # or any module

# Rebuild and switch
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Update all flake inputs (nixpkgs, home-manager, lanzaboote, etc.)
nix flake update --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Roll back to previous generation
sudo nixos-rebuild switch --flake /etc/nixos#nixos --rollback
```

Every rebuild with lanzaboote active automatically signs the new generation's EFI files. The LUKS passphrase prompt appears once per boot in the initrd. KDE Plasma 6 starts in Wayland by default through SDDM.

## Conclusion

This configuration achieves a **defense-in-depth security posture** — Secure Boot validates the boot chain's integrity, LUKS2 encrypts all data at rest, and the entire system is declaratively defined and reproducible from version-controlled Nix files. The stack runs on current, well-supported technologies: lanzaboote v1.0.0 is production-ready, NVIDIA's open kernel modules are the official recommendation for Ada Lovelace GPUs, and KDE Plasma 6's Wayland session is the default compositor.

The key architectural insight is that **lanzaboote and NVIDIA coexist without module signing conflicts** because NixOS builds kernel modules as part of the system closure rather than using DKMS. This eliminates the most common pain point of running proprietary GPU drivers with Secure Boot on Linux. The nix-flatpak module fills the gap for apps like Bitwarden and Slack that benefit from Flatpak sandboxing, while keeping their management declarative rather than imperative. Version-pin everything in `flake.lock`, commit `/etc/nixos` to Git, and you have a fully reproducible desktop that can be rebuilt identically on new hardware.