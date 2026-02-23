{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Python Development
    python3
    python3Packages.virtualenv

    # IDEs and Editors
    vscode
    jetbrains.pycharm
    jetbrains.webstorm
  ];
}
