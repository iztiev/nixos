{ ... }: {
  imports = [
    ./firefox/default.nix
    ./kde/default.nix
    ./ssh/default.nix
    # ./sops.nix
  ];
}
