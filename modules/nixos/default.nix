{ ... }: {
  imports = [
    ./nvidia.nix
    ./kde.nix
    ./cosmic.nix
    ./secure-boot.nix
    ./steam.nix
    ./printer-scanner.nix
  ];
}
