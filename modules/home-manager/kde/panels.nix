{ config, lib, ... }:

let
  cfg = config.development;

  baseLaunchers = [
    "applications:org.kde.dolphin.desktop"
    "applications:org.kde.konsole.desktop"
    "applications:firefox.desktop"
    "applications:chromium-browser.desktop"
  ];

  ideLaunchers =
    lib.optional cfg.python.enable "applications:pycharm.desktop"
    ++ lib.optional cfg.web.enable "applications:webstorm.desktop"
    ++ lib.optional cfg.go.enable "applications:goland.desktop";

  panelWidgets = [
    { kickoff = {}; }
    {
      iconTasks = {
        launchers = baseLaunchers ++ ideLaunchers;
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
  xdg.desktopEntries = lib.mkMerge [
    (lib.mkIf cfg.python.enable {
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
    })

    (lib.mkIf cfg.web.enable {
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
    })

    (lib.mkIf cfg.go.enable {
      goland = {
        name = "GoLand";
        genericName = "Go IDE";
        comment = "Go IDE from JetBrains";
        exec = "goland %f";
        icon = "goland";
        terminal = false;
        categories = [ "Development" "IDE" ];
        type = "Application";
        startupNotify = true;
        settings = {
          StartupWMClass = "jetbrains-goland";
        };
      };
    })
  ];

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
