{ config, lib, pkgs, ... }: {
  options.development.python.enable = lib.mkEnableOption "Python development environment";

  config = lib.mkIf config.development.python.enable {
    home.packages = with pkgs; [
      python314
      python314Packages.virtualenv
      jetbrains.pycharm
    ];
  };
}
