{ ... }: {
  imports = [
    ./nvidia.nix
    ./desktop.nix
    ./secure-boot.nix
  ];
}
