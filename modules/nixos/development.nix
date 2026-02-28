{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Build Tools
    gcc

    # Python Development
    python314
    python314Packages.virtualenv

    # Node.js / JavaScript
    nodejs

    # IDEs and Editors
    vscode
    jetbrains.pycharm
    jetbrains.webstorm
  ];
}
