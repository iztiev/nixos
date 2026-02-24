{ ... }:

{
  # KDE Konsole configuration
  xdg.configFile."konsolerc" = {
    source = ./files/konsolerc;
    force = true;
  };

  # KDE Konsole profile (in ~/.local/share/konsole/)
  xdg.dataFile."konsole/Izosevka.profile" = {
    source = ./files/Izosevka.profile;
    force = true;
  };
}
