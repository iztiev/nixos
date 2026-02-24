{ ... }:

{
  # KDE Konsole configuration
  xdg.configFile."konsolerc" = {
    force = true;
    text = ''
      [Desktop Entry]
      DefaultProfile=Izosevka.profile

      [General]
      ConfigVersion=1

      [KonsoleWindow]
      ShowMenuBarByDefault=false

      [Notification Messages]
      CloseSessionsWithProcesses=false

      [UiSettings]
      ColorScheme=
    '';
  };

  # KDE Konsole profile (in ~/.local/share/konsole/)
  xdg.dataFile."konsole/Izosevka.profile" = {
    force = true;
    text = ''
      [Appearance]
      Font=Izosevka,16,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

      [General]
      Name=Izosevka
      Parent=FALLBACK/

      [Scrolling]
      HistoryMode=2
    '';
  };
}
