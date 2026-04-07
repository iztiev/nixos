{ inputs, system }:
final: prev:
  let
    customPkgs = import ../pkgs { pkgs = prev; };
    stable = inputs.nixpkgs-stable.legacyPackages.${system};
  in
  customPkgs // {
    #bitwarden-desktop = stable.bitwarden-desktop; # example how to use package from stable channel
  }
