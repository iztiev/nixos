{ lib, ... }:

let
  launchers = [
    "applications:org.kde.dolphin.desktop"
    "applications:org.kde.konsole.desktop"
    "applications:firefox.desktop"
    "applications:chromium-browser.desktop"
    "applications:pycharm.desktop"
    "applications:webstorm.desktop"
  ];

  panelWidgets = [
    { kickoff = {}; }
    {
      iconTasks = {
        launchers = launchers;
        behavior = {
          grouping.method = "none";
          middleClickAction = "close";
          showTasks.onlyInCurrentScreen = true;
        };
      };
    }
    "org.kde.plasma.marginsseparator"
    { systemTray = {}; }
    { digitalClock = {}; }
    "org.kde.plasma.showdesktop"
  ];
in

{
  # ── Desktop Entries for JetBrains IDEs ──
  # Fix taskbar icons by creating custom desktop entries
  xdg.desktopEntries = {
    pycharm = {
      name = "PyCharm";
      genericName = "Python IDE";
      comment = "Python IDE from JetBrains";
      exec = "pycharm %f";
      icon = "pycharm";
      terminal = false;
      categories = [ "Development" "IDE" ];
      type = "Application";
      startupNotify = true;
      settings = {
        StartupWMClass = "jetbrains-pycharm";
      };
    };

    webstorm = {
      name = "WebStorm";
      genericName = "JavaScript IDE";
      comment = "JavaScript IDE from JetBrains";
      exec = "webstorm %f";
      icon = "webstorm";
      terminal = false;
      categories = [ "Development" "IDE" ];
      type = "Application";
      startupNotify = true;
      settings = {
        StartupWMClass = "jetbrains-webstorm";
      };
    };
  };

  # ── KDE Plasma Panels ──
  programs.plasma.panels = [
    {
      location = "bottom";
      height = 44;
      floating = true;
      screen = [ 0 1 ];
      widgets = panelWidgets;
    }
  ];
}
