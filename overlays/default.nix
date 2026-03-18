{ inputs, system }:
final: prev:
  let
    customPkgs = import ../pkgs { pkgs = prev; };
    stable = inputs.nixpkgs-stable.legacyPackages.${system};
  in
  customPkgs // {
    bitwarden-desktop = stable.bitwarden-desktop; # TODO remove after it is fixed
  }
