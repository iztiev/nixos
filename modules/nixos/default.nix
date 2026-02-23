{ ... }: {
  imports = [
    ./nvidia.nix
    ./kde.nix
    ./cosmic.nix
    ./secure-boot.nix
    ./sops.nix
    ./steam.nix
    ./printer-scanner.nix
    ./docker.nix
    ./woeusb.nix
    ./v2ray.nix
    ./development.nix
  ];
}
