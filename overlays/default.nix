{ inputs, system }:
final: prev:
  let
    customPkgs = import ../pkgs { pkgs = prev; };
    stable = inputs.nixpkgs-stable.legacyPackages.${system};
  in
  customPkgs // {
    #bitwarden-desktop = stable.bitwarden-desktop; # example how to use package from stable channel

    # Pin claude-code to nixpkgs rev where 2.1.86 builds (unstable has broken 2.1.88)
    claude-code =
      (import inputs.nixpkgs-claude-code { inherit system; config.allowUnfree = true; }).claude-code;
  }
