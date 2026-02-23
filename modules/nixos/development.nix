{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Build Tools
    gcc

    # Python Development
    python3
    python3Packages.virtualenv

    # IDEs and Editors
    vscode
    jetbrains.pycharm
    jetbrains.webstorm
  ];
}
