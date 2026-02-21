{ config, pkgs, lib, ... }:
let
  # Script to set printer quality defaults
  setPrinterQuality = pkgs.writeShellScriptBin "set-printer-quality" ''
    #!/usr/bin/env bash
    # Set high-quality print defaults for all configured printers

    echo "Setting print quality to highest for all printers..."

    for printer in $(lpstat -p | awk '{print $2}'); do
      echo "Configuring $printer..."

      # Set high quality/resolution (options vary by driver)
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o print-quality=5 2>/dev/null || true
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o PrintQuality=High 2>/dev/null || true
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o Quality=High 2>/dev/null || true

      # Set maximum resolution (common Epson settings)
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o Resolution=360dpi 2>/dev/null || true
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o EpsonInk=CMYK 2>/dev/null || true

      # Set A4 as default paper size for this printer
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o media=iso_a4_210x297mm 2>/dev/null || true

      echo "Done configuring $printer"
    done

    echo ""
    echo "Print quality settings applied. To verify, run:"
    echo "  lpoptions -p <printer-name> -l"
  '';
in
{
  # ── Printing (CUPS) ──
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint              # High-quality printer drivers
      epson-escpr             # Epson ESC/P-R driver
      epson-escpr2            # Epson ESC/P-R driver (newer models)
    ];

    # Set A4 as default paper size and high-quality defaults
    extraConf = ''
      DefaultPaperSize A4
    '';
  };

  # Set system-wide paper size to A4
  environment.etc."papersize".text = "a4";

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ── Scanning (SANE) ──
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan           # Network scanner support (eSCL/WSD)
    ];
    # Default sane-backends includes epson2 backend which supports L3258
  };

  # Add user to scanner group
  users.users.iztiev.extraGroups = [ "scanner" "lp" ];

  # ── Printer/Scanner Management Applications ──
  environment.systemPackages = with pkgs; [
    system-config-printer  # GUI for managing printers
    simple-scan            # Simple scanning application
    libpaper               # Paper size configuration library
    setPrinterQuality      # Script to set high-quality print defaults
  ];
}
