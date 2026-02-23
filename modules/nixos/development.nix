{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Build Tools
    gcc

    # Python Development
    python314
    python314Packages.virtualenv

    # IDEs and Editors
    vscode
    jetbrains.pycharm
    jetbrains.webstorm
  ];
}
