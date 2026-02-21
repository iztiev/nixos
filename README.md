# rhea — NixOS configuration

NixOS 25.11 flakes-based system configuration for host **rhea**.

**Stack:** LUKS2 full-disk encryption · LVM · AMD CPU · NVIDIA RTX 4080 Super (open kernel module, Wayland) · KDE Plasma 6 + SDDM · lanzaboote Secure Boot · nix-flatpak · Home Manager

---

## Repository layout

```
flake.nix                       # All inputs + nixosConfigurations.rhea
nixos/
  configuration.nix             # Core system config
  hardware-configuration.nix    # Machine-specific (generated on target, not committed)
modules/
  nixos/
    default.nix                 # Imports nvidia + desktop + secure-boot
    nvidia.nix                  # NVIDIA RTX 4080 Super, open module, Wayland vars
    desktop.nix                 # KDE Plasma 6, SDDM (Wayland)
    secure-boot.nix             # lanzaboote replaces systemd-boot
  home-manager/
    default.nix                 # Empty — reserved for shared HM modules
home-manager/
  home.nix                      # iztiev user: packages, Firefox, git, bash
overlays/default.nix            # Custom nixpkgs overlays (empty stub)
pkgs/default.nix                # Custom derivations (empty stub)
```

---

## Fresh installation

### 1. Boot the installer

Download the NixOS 25.11 minimal ISO from <https://nixos.org/download/>, flash to USB, and boot in **UEFI mode** with Secure Boot **disabled** in firmware.

```bash
sudo -i
```

### 2. Partition the NVMe drive

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 2048MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 2048MiB 100%
```

### 3. LUKS2 encryption + LVM

```bash
cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot

pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 32G -n swap vg
lvcreate -l 100%FREE -n root vg

mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/vg/root
mkswap -L swap /dev/vg/swap
```

### 4. Mount and generate hardware config

```bash
mount /dev/vg/root /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/vg/swap

nixos-generate-config --root /mnt
```

Keep the generated `/mnt/etc/nixos/hardware-configuration.nix` — it contains your LUKS UUID.

### 5. Minimal first install (no flakes yet)

Edit `/mnt/etc/nixos/configuration.nix` to a minimal config so the system boots:

```nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."cryptroot".allowDiscards = true;
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true;

  networking.hostName = "rhea";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.iztiev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [ vim git ];
  system.stateVersion = "25.11";
}
```

```bash
nixos-install
reboot
```

Log in as `iztiev` and change your password:

```bash
passwd
```

### 6. Clone this repo and switch to the flake config

```bash
sudo git clone https://github.com/iztiev/nixos /etc/nixos
```

Copy the generated hardware config into the repo:

```bash
sudo nixos-generate-config --show-hardware-config | sudo tee /etc/nixos/nixos/hardware-configuration.nix
```

Build and switch (lanzaboote is active in this config — see **Secure Boot setup** below before running):

```bash
sudo nixos-rebuild switch --flake /etc/nixos#rhea
```

---

## Secure Boot setup

Secure Boot is enabled by default via `modules/nixos/secure-boot.nix`. Before the first flake build you must generate signing keys, otherwise lanzaboote will fail.

### Generate keys (once, on the target machine)

```bash
sudo nix run nixpkgs#sbctl create-keys
```

Keys are stored in `/var/lib/sbctl/`. Now rebuild:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#rhea
```

Verify all EFI files are signed:

```bash
sudo sbctl verify
```

### Enroll keys in firmware

1. Reboot into UEFI/BIOS (usually DEL or F2 during POST)
2. Navigate to **Secure Boot** → enter **Setup Mode** (clear existing keys)
3. Save and exit — boot back into NixOS
4. Enroll your keys plus Microsoft's keys (required for NVIDIA VBIOS compatibility):

```bash
sudo sbctl enroll-keys --microsoft
```

5. Reboot and verify:

```bash
sudo bootctl status    # Secure Boot: enabled
sudo sbctl status      # Setup Mode: Disabled, Secure Boot: Enabled
```

Every subsequent `nixos-rebuild switch` automatically signs new EFI files.

---

## Daily workflow

```bash
# Rebuild and activate
rebuild
# (alias for: sudo nixos-rebuild switch --flake /etc/nixos#rhea)

# Update all flake inputs
update
# (alias for: nix flake update --flake /etc/nixos)
# Then rebuild to apply

# Test a config change without making it permanent across reboots
sudo nixos-rebuild test --flake /etc/nixos#rhea

# Roll back to the previous generation
sudo nixos-rebuild switch --flake /etc/nixos#rhea --rollback

# List all generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

---

## Verifying the stack

```bash
nvidia-smi                    # NVIDIA driver loaded
echo $XDG_SESSION_TYPE        # wayland
sudo bootctl status           # Secure Boot: enabled
lsblk                         # cryptroot LUKS device visible
flatpak list                  # Bitwarden, Slack, Telegram Desktop
fc-list | grep Izosevka       # Izosevka font present
claude --version              # Claude Code available
```

---

## What's installed

### System (all users)

| Component | Detail |
|---|---|
| Bootloader | lanzaboote (Secure Boot, signed EFI per generation) |
| Encryption | LUKS2 + LVM on NVMe |
| CPU | AMD (KVM + microcode updates) |
| GPU | NVIDIA RTX 4080 Super, open kernel module |
| Desktop | KDE Plasma 6 (Wayland) |
| Display manager | SDDM (Wayland) |
| Audio | PipeWire (ALSA + PulseAudio compat + 32-bit) |
| Flatpak apps | Bitwarden, Slack, Telegram Desktop |
| Font | Izosevka |
| Utilities | vim, git, wget, curl, sbctl, nvidia-vaapi-driver |

### User — iztiev (Home Manager)

| Category | Packages |
|---|---|
| Browsers | Firefox (uBlock Origin + Stylus), Chromium |
| Development | Claude Code, PyCharm, WebStorm |
| Utilities | htop, ripgrep, fd, unzip |
| Shell | Bash + completion, `rebuild` / `update` aliases |
