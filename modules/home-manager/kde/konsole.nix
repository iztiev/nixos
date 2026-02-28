{ ... }:

{
  programs.konsole = {
    enable = true;
    defaultProfile = "Izosevka";

    profiles.Izosevka = {
      font = {
        name = "Izosevka";
        size = 16;
      };
      extraConfig = {
        Scrolling.HistoryMode = 2;
      };
    };

    extraConfig = {
      KonsoleWindow.ShowMenuBarByDefault = false;
      "Notification Messages".CloseSessionsWithProcesses = false;
    };
  };

  # Remap terminal shortcuts: Ctrl+C=Copy, Ctrl+V=Paste, Ctrl+Shift+C=Interrupt
  xdg.dataFile."kxmlgui5/konsole/sessionui.rc" = {
    force = true;
    source = ./files/sessionui.rc;
  };
}
