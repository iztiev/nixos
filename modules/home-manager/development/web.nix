{ config, lib, pkgs, ... }: {
  options.development.web.enable = lib.mkEnableOption "Web development environment";

  config = lib.mkIf config.development.web.enable {
    home.packages = with pkgs; [
      nodejs
      jetbrains.webstorm
    ];
  };
}
