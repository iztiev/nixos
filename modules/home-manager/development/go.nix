{ config, lib, pkgs, ... }: {
  options.development.go.enable = lib.mkEnableOption "Go development environment";

  config = lib.mkIf config.development.go.enable {
    home.packages = with pkgs; [
      go
      gopls
      jetbrains.goland
    ];
  };
}
