{ inputs, system }:
final: prev:
  let
    customPkgs = import ../pkgs { pkgs = prev; };
    stable = inputs.nixpkgs-stable.legacyPackages.${system};
  in
  customPkgs // {
    #bitwarden-desktop = stable.bitwarden-desktop; # example how to use package from stable channel
    # openldap = prev.openldap.overrideAttrs (_: {
    #   doCheck = !prev.stdenv.hostPlatform.isi686; # Temporary fix for openldap 2.6.13 issue (https://github.com/NixOS/nixpkgs/issues/514113)
    # });
  }
