{ config, pkgs, lib, ... }:
let
  # Script to set printer quality defaults
  # Run once after adding a printer to apply best-quality defaults
  setPrinterQuality = pkgs.writeShellScriptBin "set-printer-quality" ''
    #!/usr/bin/env bash
    # Set high-quality print defaults for all configured printers

    echo "Setting print quality to highest for all printers..."

    for printer in $(lpstat -p | awk '{print $2}'); do
      echo "Configuring $printer..."

      # epson-escpr (older PPD): uses a combined MediaType/Quality option
      # PLAIN_HIGH = plain paper at high quality
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o MediaType=PLAIN_HIGH 2>/dev/null || true

      # epson-escpr2 (newer PPD): separate MediaType and cupsPrintQuality options
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o cupsPrintQuality=High 2>/dev/null || true

      # Set A4 as default paper size
      ${pkgs.cups}/bin/lpadmin -p "$printer" -o media=iso_a4_210x297mm 2>/dev/null || true

      echo "Done configuring $printer"
    done

    echo ""
    echo "Print quality settings applied. To verify available options, run:"
    echo "  lpoptions -p <printer-name> -l"
    echo "To check current defaults:"
    echo "  lpoptions -p <printer-name>"
  '';
in
{
  # ── Printing (CUPS) ──
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      epson-escpr             # Epson ESC/P-R driver (L-series EcoTank, older models)
      epson-escpr2            # Epson ESC/P-R 2 driver (newer models)
      # Note: gutenprint intentionally excluded — it provides generic PPDs that
      # can override Epson's native driver and reduce print quality
    ];

    # Set A4 as default paper size
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

  # Add user to scanner group
  users.users.iztiev.extraGroups = [ "scanner" "lp" ];

  # ── Printer/Scanner Management Applications ──
  environment.systemPackages = with pkgs; [
    system-config-printer  # GUI for managing printers
    simple-scan            # Simple scanning application
    libpaper               # Paper size configuration library
    setPrinterQuality      # Script to apply high-quality print defaults
    # epsonscan2 GUI is installed via hardware.sane.extraBackends above
  ];
}
