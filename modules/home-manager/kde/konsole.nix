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
}
