final: prev:
  let
    customPkgs = import ../pkgs { pkgs = prev; };
  in
  customPkgs
