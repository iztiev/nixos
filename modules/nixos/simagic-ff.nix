{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.simagic-ff;

  simagic-ff-module = config.boot.kernelPackages.callPackage
    ({ lib, stdenv, fetchFromGitHub, kernel }:
      stdenv.mkDerivation {
        pname = "simagic-ff";
        version = "2.0.0";

        src = fetchFromGitHub {
          owner = "JacKeTUs";
          repo = "simagic-ff";
          rev = "ef7f79001da436843120e2a87a26860d9e56b050";
          hash = "sha256-kFXyADTapJo+jZd2UqTMEmG6AA7+lmJZeKNd2n1jwOc=";
        };

        hardeningDisable = [ "pic" ];
        nativeBuildInputs = kernel.moduleBuildDependencies;

        makeFlags = [
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "INSTALL_MOD_PATH=$(out)"
        ];

        installPhase = ''
          install -D hid-simagic-ff.ko \
            $out/lib/modules/${kernel.modDirVersion}/extra/hid-simagic-ff.ko
        '';

        meta = with lib; {
          description = "Force feedback support for Simagic wheelbases";
          homepage = "https://github.com/JacKeTUs/simagic-ff";
          license = licenses.gpl2Only;
          platforms = platforms.linux;
        };
      }
    ) {};
in
{
  options.services.simagic-ff = {
    enable = mkEnableOption "Simagic force feedback wheel driver";

    vendorId = mkOption {
      type = types.str;
      default = "3670";
      description = "Simagic USB vendor ID";
    };

    productId = mkOption {
      type = types.str;
      default = "0501";
      description = "Simagic USB product ID as reported by lsusb (may differ from marketing model)";
    };
  };

  config = mkIf cfg.enable {
    # Load the out-of-tree simagic-ff kernel module
    boot.extraModulePackages = [ simagic-ff-module ];
    boot.kernelModules = [ "hid-simagic-ff" "uinput" "joydev" ];

    # Fix GT Neo steering wheel infinite reboot polling bug
    boot.kernelParams = [
      "usbhid.quirks=0x${cfg.vendorId}:${cfg.productId}:0x0400"
    ];

    # Udev rules for device access and FFB write permissions
    services.udev.extraRules = ''
      # hidraw access for SimPro Manager and direct HID communication
      KERNEL=="hidraw*", ATTRS{idVendor}=="${cfg.vendorId}", MODE="0666", TAG+="uaccess"
      # Joystick tagging for input subsystem
      SUBSYSTEM=="input", ATTRS{idVendor}=="${cfg.vendorId}", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # FFB write access on event devices
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="${cfg.vendorId}", MODE="0666"
    '';

    # Diagnostic packages for testing wheel input and FFB
    environment.systemPackages = with pkgs; [
      evtest
      linuxConsoleTools
      sdl-jstest
      usbutils
    ];
  };
}
