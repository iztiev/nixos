# KDE Application Configuration

## Konsole (`apps.konsole`)

```nix
programs.plasma.apps.konsole = {
  defaultProfile = "MyProfile";

  profiles = {
    MyProfile = {
      colorScheme = "Breeze";      # Color scheme name
      command = "/run/current-system/sw/bin/bash";
      font = {
        family = "JetBrains Mono";
        pointSize = 12;
      };
      extraConfig = {
        General = {
          TerminalCenter = true;
          TerminalMargin = 10;
        };
        Scrolling = {
          HistoryMode = 1;          # 0=none, 1=fixed, 2=unlimited
          HistorySize = 10000;
        };
      };
    };
  };

  # Custom color schemes (path to .colorscheme files)
  customColorSchemes = {
    "MyTheme" = ./konsole-themes/MyTheme.colorscheme;
  };
};
```

## Kate (`apps.kate`)

Large configuration module. Key sections:

```nix
programs.plasma.apps.kate = {
  # Editor settings
  editor = {
    indent = {
      width = 4;
      autodetect = true;
      keepExtraSpaces = false;
      replaceWithSpaces = true;    # Spaces instead of tabs
      showLines = true;             # Show indentation guides
    };
    font = {
      family = "JetBrains Mono";
      pointSize = 12;
    };
    brackets = {
      automaticallyAddClosing = true;
      flashMatching = true;
      highlightMatching = true;
      highlightRange = true;
    };
  };

  # Session restore
  sessionRestore = "lastSession";   # lastSession, newEmptySession, newSessionFromDir

  # Tabs
  tabBar = {
    limit = 0;                      # 0 = unlimited
    closeButtonOnTabs = true;
    doubleClickNewTab = true;
    showTabCloseButton = true;
    showTabIndex = false;
  };

  # Scrollbar
  scrollbar = {
    miniMap.enable = false;
    showMarks = true;
    showMiniMap = false;
  };
};
```

## Okular (`apps.okular`)

```nix
programs.plasma.apps.okular = {
  # General settings
  general = {
    openFileInTabs = true;
    obeyDRM = true;
    showScrollBars = true;
  };
};
```

## Elisa (`apps.elisa`)

Music player configuration:

```nix
programs.plasma.apps.elisa = {
  # Elisa-specific settings
};
```

## Ghostwriter (`apps.ghostwriter`)

Markdown editor configuration:

```nix
programs.plasma.apps.ghostwriter = {
  # Ghostwriter-specific settings
};
```

## Any KDE App via configFile

For apps without dedicated modules, use `configFile`:

```nix
configFile = {
  # Dolphin
  dolphinrc.General = {
    ShowFullPath = true;
    ShowHiddenFiles = false;
    SortHiddenLast = true;
    ViewPropsTimestamp = "2024,1,1,0,0,0";
  };

  # Gwenview
  gwenviewrc.General = {
    BackgroundColorMode = "black";
    ThumbnailBarIsVisible = true;
  };

  # Any app that stores config in ~/.config/<appname>rc
  "<appname>rc"."Group"."Key" = "value";
};
```
