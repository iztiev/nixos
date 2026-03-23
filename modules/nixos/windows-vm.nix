{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.windows-vm;

  qemu-smb = pkgs.qemu_kvm.override { smbdSupport = true; };

  virtio-win = pkgs.virtio-win;

  # Build an ISO with driver .inf trees (for Device Manager) and the EXE installer
  virtio-win-iso = pkgs.runCommand "virtio-win-drivers.iso" {
    nativeBuildInputs = [ pkgs.cdrkit ];
  } ''
    mkdir -p staging
    # Copy the standalone EXE installer and MSIs
    cp ${virtio-win}/virtio-win-guest-tools.exe staging/
    cp ${virtio-win}/virtio-win-gt-x64.msi staging/
    # Copy W11 amd64 driver directories (for manual Device Manager install)
    for drv in viogpudo NetKVM Balloon viostor vioserial viorng; do
      if [ -d "${virtio-win}/$drv/w11/amd64" ]; then
        mkdir -p "staging/$drv"
        cp -r "${virtio-win}/$drv/w11/amd64/"* "staging/$drv/"
      fi
    done
    mkisofs -o $out -J -R -V "VIRTIO-WIN" staging/
  '';

  # OVMF with Secure Boot + Microsoft keys enrolled
  ovmf-sb = (pkgs.OVMF.override {
    secureBoot = true;
    msVarsTemplate = true;
    tpmSupport = true;
  }).fd;

  stateDir = cfg.stateDir;

  # Script to launch the VM with direct raw disk passthrough
  windowsVmScript = pkgs.writeShellScriptBin "windows-vm" ''
    DISK="${cfg.disk}"
    STATE_DIR="${stateDir}"
    VARS_FILE="$STATE_DIR/OVMF_VARS.ms.fd"
    TPM_DIR="$STATE_DIR/tpm"

    if [ "$(id -u)" -ne 0 ]; then
      echo "ERROR: windows-vm must be run as root (use the 'windows' alias)."
      exit 1
    fi

    if [ -z "''${SUDO_USER:-}" ]; then
      echo "ERROR: run via sudo so we know which user to drop back to."
      exit 1
    fi

    CALLING_UID=$(id -u "$SUDO_USER")
    CALLING_GID=$(id -g "$SUDO_USER")

    # Safety check: make sure no NTFS partitions from this disk are mounted
    if mount | grep -q "$DISK"; then
      echo "ERROR: $DISK (or a partition) is currently mounted. Unmount it first."
      exit 1
    fi

    # ── Root-only setup ──
    mkdir -p "$STATE_DIR" "$TPM_DIR"

    # Copy the UEFI vars template on first run (must be writable for NVRAM)
    if [ ! -f "$VARS_FILE" ]; then
      cp ${ovmf-sb}/FV/OVMF_VARS.ms.fd "$VARS_FILE"
      echo "Initialized UEFI Secure Boot variables at $VARS_FILE"
    fi



    # Ensure the entire state dir is owned by the calling user and writable
    chown -R "$CALLING_UID:$CALLING_GID" "$STATE_DIR"
    chmod 644 "$VARS_FILE"

    # Grant the calling user read/write access to the raw disk for this session
    chown "$CALLING_UID:$CALLING_GID" "$DISK"

    cleanup() {
      # Restore disk ownership to root
      chown root:root "$DISK" 2>/dev/null
      kill "$SWTPM_PID" 2>/dev/null
    }
    trap cleanup EXIT

    # ── Start software TPM as the calling user ──
    sudo -u "$SUDO_USER" ${pkgs.swtpm}/bin/swtpm socket \
      --tpmstate dir="$TPM_DIR" \
      --ctrl type=unixio,path="$TPM_DIR/swtpm-sock" \
      --tpm2 \
      --log level=0 &
    SWTPM_PID=$!

    # Brief wait for swtpm socket
    sleep 0.3

    # ── Launch QEMU as the calling user (audio/display work natively) ──
    sudo -u "$SUDO_USER" \
      env DISPLAY="''${DISPLAY:-:0}" \
          WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-}" \
          XDG_RUNTIME_DIR="/run/user/$CALLING_UID" \
          PULSE_SERVER="/run/user/$CALLING_UID/pulse/native" \
      ${qemu-smb}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -machine q35,accel=kvm,smm=on \
      -global driver=cfi.pflash01,property=secure,value=on \
      -cpu host \
      -smp ${toString cfg.cores},sockets=1,cores=${toString cfg.cores},threads=1 \
      -m ${toString cfg.memoryMB} \
      -drive if=pflash,format=raw,unit=0,file=${ovmf-sb}/FV/OVMF_CODE.ms.fd,readonly=on \
      -drive if=pflash,format=raw,unit=1,file="$VARS_FILE" \
      -chardev socket,id=chrtpm,path="$TPM_DIR/swtpm-sock" \
      -tpmdev emulator,id=tpm0,chardev=chrtpm \
      -device tpm-tis,tpmdev=tpm0 \
      -drive file="$DISK",format=raw,if=none,id=disk0,cache=none,aio=native \
      -device ahci,id=ahci \
      -device ide-hd,drive=disk0,bus=ahci.0 \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,smb=${cfg.sharedDir} \
      -display sdl \
      -device virtio-vga,xres=3840,yres=2160,edid=on \
      -drive file=${virtio-win-iso},index=1,media=cdrom \
      -device qemu-xhci -device usb-tablet \
      -device intel-hda -device hda-duplex \
      "$@"
  '';
in
{
  options.services.windows-vm = {
    enable = mkEnableOption "Windows VM (raw disk passthrough)";

    disk = mkOption {
      type = types.str;
      default = "/dev/nvme1n1";
      description = "Block device containing the Windows installation.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/windows-vm";
      description = "Directory to store UEFI NVRAM variables and TPM state.";
    };

    sharedDir = mkOption {
      type = types.str;
      default = "/home/iztiev";
      description = "Host directory exported to the VM via built-in SMB (accessible as \\\\10.0.2.4\\qemu in Windows).";
    };

    cores = mkOption {
      type = types.int;
      default = 4;
      description = "Number of CPU cores for the VM.";
    };

    memoryMB = mkOption {
      type = types.int;
      default = 8192;
      description = "RAM in MB for the VM.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      windowsVmScript
      qemu-smb
      pkgs.swtpm
    ];

    # Allow the user to access KVM and raw disk
    users.users.iztiev.extraGroups = [ "kvm" "disk" ];

    # Preserve display env vars when running windows-vm with sudo
    security.sudo.extraRules = [{
      users = [ "iztiev" ];
      commands = [{
        command = "${windowsVmScript}/bin/windows-vm";
        options = [ "NOPASSWD" "SETENV" ];
      }];
    }];
  };
}
