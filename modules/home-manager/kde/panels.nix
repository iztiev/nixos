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
    force = true;
    text = ''
      [ActionPlugins][0]
      MiddleButton;NoModifier=org.kde.paste
      RightButton;NoModifier=org.kde.contextmenu

      [ActionPlugins][1]
      RightButton;NoModifier=org.kde.contextmenu

      [Containments][197]
      activityId=
      formfactor=2
      immutability=1
      lastScreen[$i]=0
      location=4
      plugin=org.kde.panel
      wallpaperplugin=org.kde.image

      [Containments][197][Applets][198]
      immutability=1
      plugin=org.kde.plasma.kickoff

      [Containments][197][Applets][198][Configuration]
      popupHeight=509
      popupWidth=647

      [Containments][197][Applets][198][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][197][Applets][198][Configuration][General]
      favoritesPortedToKAstats=true

      [Containments][197][Applets][199]
      immutability=1
      plugin=org.kde.plasma.icontasks

      [Containments][197][Applets][199][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][197][Applets][199][Configuration][General]
      groupingStrategy=0
      launchers=applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:chromium-browser.desktop,applications:pycharm.desktop,applications:webstorm.desktop
      middleClickAction=Close
      showOnlyCurrentScreen=true

      [Containments][197][Applets][200]
      immutability=1
      plugin=org.kde.plasma.marginsseparator

      [Containments][197][Applets][201]
      activityId=
      formfactor=0
      immutability=1
      lastScreen=-1
      location=0
      plugin=org.kde.plasma.systemtray
      popupHeight=432
      popupWidth=432
      wallpaperplugin=org.kde.image

      [Containments][197][Applets][201][Applets][202]
      immutability=1
      plugin=org.kde.plasma.manage-inputmethod

      [Containments][197][Applets][201][Applets][203]
      immutability=1
      plugin=org.kde.plasma.notifications

      [Containments][197][Applets][201][Applets][204]
      immutability=1
      plugin=org.kde.plasma.clipboard

      [Containments][197][Applets][201][Applets][205]
      immutability=1
      plugin=org.kde.plasma.devicenotifier

      [Containments][197][Applets][201][Applets][206]
      immutability=1
      plugin=org.kde.plasma.cameraindicator

      [Containments][197][Applets][201][Applets][207]
      immutability=1
      plugin=org.kde.plasma.keyboardlayout

      [Containments][197][Applets][201][Applets][208]
      immutability=1
      plugin=org.kde.plasma.volume

      [Containments][197][Applets][201][Applets][208][Configuration][General]
      migrated=true

      [Containments][197][Applets][201][Applets][209]
      immutability=1
      plugin=org.kde.plasma.networkmanagement

      [Containments][197][Applets][201][Applets][210]
      immutability=1
      plugin=org.kde.plasma.printmanager

      [Containments][197][Applets][201][Applets][211]
      immutability=1
      plugin=org.kde.plasma.weather

      [Containments][197][Applets][201][Applets][212]
      immutability=1
      plugin=org.kde.plasma.keyboardindicator

      [Containments][197][Applets][201][Applets][213]
      immutability=1
      plugin=org.kde.kscreen

      [Containments][197][Applets][201][Applets][237]
      immutability=1
      plugin=org.kde.plasma.brightness

      [Containments][197][Applets][201][Applets][238]
      immutability=1
      plugin=org.kde.plasma.battery

      [Containments][197][Applets][201][Applets][242]
      immutability=1
      plugin=org.kde.plasma.mediacontroller

      [Containments][197][Applets][201][General]
      extraItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen
      knownItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen

      [Containments][197][Applets][214]
      immutability=1
      plugin=org.kde.plasma.digitalclock

      [Containments][197][Applets][214][Configuration]
      popupHeight=400
      popupWidth=560

      [Containments][197][Applets][215]
      immutability=1
      plugin=org.kde.plasma.showdesktop

      [Containments][197][General]
      AppletOrder=198;199;200;201;214;215

      [Containments][216]
      activityId=
      formfactor=2
      immutability=1
      lastScreen[$i]=1
      location=4
      plugin=org.kde.panel
      wallpaperplugin=org.kde.image

      [Containments][216][Applets][217]
      immutability=1
      plugin=org.kde.plasma.kickoff

      [Containments][216][Applets][217][Configuration]
      popupHeight=509
      popupWidth=647

      [Containments][216][Applets][217][Configuration][General]
      favoritesPortedToKAstats=true

      [Containments][216][Applets][218]
      immutability=1
      plugin=org.kde.plasma.icontasks

      [Containments][216][Applets][218][Configuration][ConfigDialog]
      DialogHeight=630
      DialogWidth=810

      [Containments][216][Applets][218][Configuration][General]
      groupingStrategy=0
      launchers=applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:chromium-browser.desktop,applications:pycharm.desktop,applications:webstorm.desktop
      middleClickAction=Close
      showOnlyCurrentScreen=true

      [Containments][216][Applets][219]
      immutability=1
      plugin=org.kde.plasma.marginsseparator

      [Containments][216][Applets][220]
      activityId=
      formfactor=0
      immutability=1
      lastScreen=-1
      location=0
      plugin=org.kde.plasma.systemtray
      popupHeight=432
      popupWidth=432
      wallpaperplugin=org.kde.image

      [Containments][216][Applets][220][Applets][221]
      immutability=1
      plugin=org.kde.plasma.manage-inputmethod

      [Containments][216][Applets][220][Applets][222]
      immutability=1
      plugin=org.kde.plasma.notifications

      [Containments][216][Applets][220][Applets][223]
      immutability=1
      plugin=org.kde.plasma.clipboard

      [Containments][216][Applets][220][Applets][224]
      immutability=1
      plugin=org.kde.plasma.devicenotifier

      [Containments][216][Applets][220][Applets][225]
      immutability=1
      plugin=org.kde.plasma.cameraindicator

      [Containments][216][Applets][220][Applets][226]
      immutability=1
      plugin=org.kde.plasma.keyboardlayout

      [Containments][216][Applets][220][Applets][227]
      immutability=1
      plugin=org.kde.plasma.volume

      [Containments][216][Applets][220][Applets][227][Configuration][General]
      migrated=true

      [Containments][216][Applets][220][Applets][228]
      immutability=1
      plugin=org.kde.plasma.networkmanagement

      [Containments][216][Applets][220][Applets][229]
      immutability=1
      plugin=org.kde.plasma.printmanager

      [Containments][216][Applets][220][Applets][230]
      immutability=1
      plugin=org.kde.plasma.weather

      [Containments][216][Applets][220][Applets][231]
      immutability=1
      plugin=org.kde.plasma.keyboardindicator

      [Containments][216][Applets][220][Applets][232]
      immutability=1
      plugin=org.kde.kscreen

      [Containments][216][Applets][220][Applets][239]
      immutability=1
      plugin=org.kde.plasma.brightness

      [Containments][216][Applets][220][Applets][240]
      immutability=1
      plugin=org.kde.plasma.battery

      [Containments][216][Applets][220][Applets][241]
      immutability=1
      plugin=org.kde.plasma.mediacontroller

      [Containments][216][Applets][220][General]
      extraItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen
      knownItems=org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.cameraindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.weather,org.kde.plasma.keyboardindicator,org.kde.kscreen

      [Containments][216][Applets][233]
      immutability=1
      plugin=org.kde.plasma.digitalclock

      [Containments][216][Applets][233][Configuration]
      popupHeight=400
      popupWidth=560

      [Containments][216][Applets][234]
      immutability=1
      plugin=org.kde.plasma.showdesktop

      [Containments][216][General]
      AppletOrder=217;218;219;220;233;234

      [Containments][235]
      ItemGeometries-3840x2160=
      ItemGeometriesHorizontal=
      activityId=00c4b352-5d74-46f9-ab53-ab3a14d5ed49
      formfactor=0
      immutability=1
      lastScreen=0
      location=0
      plugin=org.kde.plasma.folder
      wallpaperplugin=org.kde.image

      [Containments][236]
      ItemGeometries-3840x2160=
      ItemGeometriesHorizontal=
      activityId=00c4b352-5d74-46f9-ab53-ab3a14d5ed49
      formfactor=0
      immutability=1
      lastScreen=1
      location=0
      plugin=org.kde.plasma.folder
      wallpaperplugin=org.kde.image

      [ScreenMapping]
      itemsOnDisabledScreens=
    '';
  };

  # KDE Plasma Shell configuration
  xdg.configFile."plasmashellrc" = {
    force = true;
    text = ''
      [PlasmaViews][Panel 197]
      floating=1

      [PlasmaViews][Panel 197][Defaults]
      thickness=44

      [PlasmaViews][Panel 216]
      floating=1

      [PlasmaViews][Panel 216][Defaults]
      thickness=44

      [Updates]
      performed=/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/systemloadviewer_systemmonitor.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/unlock_widgets.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/mediaframe_migrate_useBackground_setting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/containmentactions_middlebutton.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_remove_shortcut.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_font_settings.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/keyboardlayout_migrateiconsetting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/no_middle_click_paste_on_panels.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_rename_timezonedisplay_key.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/digitalclock_migrate_showseconds_setting.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/move_desktop_layout_config.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/migrate_font_weights.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/maintain_existing_desktop_icon_sizes.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/klipper_clear_config.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/taskmanager_configUpdate_wheelEnabled.js,/run/current-system/sw/share/plasma/shells/org.kde.plasma.desktop/contents/updates/folderview_fix_recursive_screenmapping.js
    '';
  };
}
