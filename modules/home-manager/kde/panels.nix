{ ... }:

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

  # ── KDE Plasma Desktop Applets Configuration ──
  # Declaratively manage Plasma desktop panel layout and applets
  xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
    source = ./files/plasma-org.kde.plasma.desktop-appletsrc;
    force = true;
  };

  # KDE Plasma Shell configuration
  xdg.configFile."plasmashellrc" = {
    source = ./files/plasmashellrc;
    force = true;
  };
}
