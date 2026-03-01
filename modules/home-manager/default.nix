{ ... }: {
  imports = [
    ./ai/default.nix
    ./development/default.nix
    ./firefox/default.nix
    ./kde/default.nix
    ./ssh/default.nix
    # ./sops.nix
  ];
}
