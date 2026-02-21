{ ... }: {
  imports = [
    ./nvidia.nix
    ./kde.nix
    ./cosmic.nix
    ./secure-boot.nix
  ];
}
