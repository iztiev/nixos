# Panels and Widgets

Panels are configured via `programs.plasma.panels` (list of panel definitions). Desktop widgets via `programs.plasma.desktop.widgets`.

## Panel Options

```nix
panels = [
  {
    location = "bottom";       # top, bottom, left, right, floating
    height = 44;               # Panel height in pixels (default: 44)
    alignment = "center";      # left, center, right
    lengthMode = "fill";       # fill, fit, custom
    # minLength = 800;         # Only with lengthMode = "custom"
    # maxLength = 1200;
    # offset = 0;              # Offset from alignment edge
    floating = true;           # Floating panel style
    hiding = "none";           # none, autohide, dodgewindows, normalpanel, windowsgobelow
    opacity = "adaptive";      # adaptive, opaque, translucent
    screen = 0;                # Monitor index, or [0 1] for multiple, or "all"
    widgets = [ ... ];         # Widget list (see below)
    # extraSettings = "...";   # Raw JavaScript for advanced panel config
  }
];
```

## Widget Specification (3 ways)

### 1. Simple string (default config)
```nix
widgets = [
  "org.kde.plasma.kickoff"
  "org.kde.plasma.icontasks"
  "org.kde.plasma.marginsseparator"
  "org.kde.plasma.panelspacer"
];
```

### 2. Name + raw config
```nix
widgets = [
  {
    name = "org.kde.plasma.kickoff";
    config = {
      General = {
        icon = "nix-snowflake-white";
        alphaSort = true;
      };
    };
  }
];
```

### 3. High-level widget options (preferred)
```nix
widgets = [
  { kickoff.icon = "nix-snowflake-white"; }
  { iconTasks.launchers = [
      "applications:org.kde.dolphin.desktop"
      "applications:org.kde.konsole.desktop"
    ];
  }
  "org.kde.plasma.marginsseparator"
  { digitalClock = {
      time.format = "24h";  # or "12h"
      calendar.firstDayOfWeek = "monday";
    };
  }
  { systemTray.items = {
      shown = [ "org.kde.plasma.battery" "org.kde.plasma.bluetooth" ];
      hidden = [ "org.kde.plasma.networkmanagement" ];
    };
  }
];
```

## Available High-Level Widgets

### kickoff (Application Launcher)
```nix
{ kickoff = {
    icon = "start-here-kde";
    label = "";                    # Button label text
    sortAlphabetically = true;
    compactMode = false;
    sidebarPosition = "left";      # left, right
    showButtonsFor = "power";      # power, session, custom, powerAndSession
    favoritesDisplayMode = "grid"; # grid, list
    applicationsDisplayMode = "list";
    pin = false;                   # Pin launcher open
  };
}
```

### iconTasks (Task Manager)
```nix
{ iconTasks = {
    launchers = [
      "applications:org.kde.dolphin.desktop"
      "applications:org.kde.konsole.desktop"
    ];
    appearance = {
      showTooltips = true;
      highlightWindows = true;
      indicateAudioStreams = true;
      fill = true;
      rows.multirowView = "never"; # never, low, medium, high, always
      iconSpacing = "medium";       # small, medium, large
    };
    behavior = {
      grouping.method = "byProgramName"; # none, byProgramName
      sortingMethod = "manually";         # none, manually, alphabetically, byDesktop, byActivity
      minimizeActiveTaskOnClick = true;
      middleClickAction = "newInstance";  # none, close, newInstance, toggleMinimized, toggleGrouping, bringToCurrentDesktop
      wheel.switchBetweenTasks = true;
      showTasks.onlyInCurrentScreen = false;
      showTasks.onlyInCurrentDesktop = true;
      showTasks.onlyInCurrentActivity = true;
      showTasks.onlyMinimized = false;
      unhideOnAttentionNeeded = true;
      newTasksAppearOn = "right";         # left, right
    };
  };
}
```

### digitalClock
```nix
{ digitalClock = {
    time = {
      format = "24h";           # 24h, 12h, default
      showSeconds = "never";    # never, onlyInTooltip, always
      showTimeZone = false;
    };
    date = {
      enable = true;
      format = "isoDate";       # adaptive, longDate, shortDate, isoDate, custom
      # customFormat = "dd/MM/yyyy";  # when format = "custom"
      position = "belowTime";   # adaptive, besideTime, belowTime
    };
    calendar = {
      firstDayOfWeek = "monday";
      plugins = [ "pim" "astronomicalevents" "alternatecalendar" ];
      showWeekNumbers = false;
    };
    font = {
      bold = false;
      family = "";               # empty = system default
      size = 0;                  # 0 = automatic
    };
    timeZone = {
      selected = [ "UTC" "Europe/Berlin" ];
      lastSelected = "UTC";
      changeOnScroll = false;
      format = "code";           # code, city, offset, abbreviation, default
      alwaysShow = false;
    };
  };
}
```

### systemTray
```nix
{ systemTray = {
    icons.scaleToFit = false;   # Scale icons to panel size
    icons.spacing = "medium";    # small, medium, large
    items = {
      shown = [                  # Always visible
        "org.kde.plasma.battery"
        "org.kde.plasma.bluetooth"
        "org.kde.plasma.volume"
        "org.kde.plasma.networkmanagement"
      ];
      hidden = [                 # Hidden in expandable area
        "org.kde.plasma.clipboard"
      ];
      # Items not listed use "auto" visibility
    };
  };
}
```

### pager (Virtual Desktop Switcher)
```nix
{ pager = {
    general = {
      displayedText = "desktopName"; # none, desktopNumber, desktopName
      showOnlyCurrentScreen = false;
      showWindowOutlines = false;
      wrapPage = false;
    };
  };
}
```

### panelSpacer
```nix
{ panelSpacer.expanding = true; }  # true = flexible, false = fixed size
```

### battery
```nix
{ battery.showPercentage = true; }
```

### keyboardLayout
```nix
{ keyboardLayout = {
    displayStyle = "flag";   # flag, label, flagAndLabel, flagAndName, nameAndFlag
    keyboardLayout.compactMode = false;
  };
}
```

### applicationTitleBar
```nix
{ applicationTitleBar = {
    behavior.activeTaskSource = "activeTask"; # activeTask, lastActiveTask, none
    layout = {
      elements = [ "windowTitle" ];  # windowCloseButton, windowMinButton, windowMaxButton, windowTitle, windowIcon, spacer
      horizontalAlignment = "left";   # left, right, center, justify
      verticalAlignment = "center";   # top, center, bottom, fill
      showDisabledElements = "deactivated"; # deactivated, hideKeepSpace, hide
      fillFreeSpace = false;
    };
    windowTitle = {
      source = "appName";            # appName, decoration, genericAppName, alwaysUndefined
      hideEmptyTitle = true;
      undefinedWindowTitle = "";
      font = {
        bold = false;
        fit = "fixedSize";           # fixedSize, fixedHeight
        size = 12;
      };
      margins = { left = 10; right = 5; top = 0; bottom = 0; };
    };
    overrideForMaximized.enable = false;
    titleReplacements = [
      { type = "regexp"; originalTitle = "^Brave Web Browser$"; newTitle = "Brave"; }
    ];
  };
}
```

### plasmusicToolbar
```nix
{ plasmusicToolbar = {
    panelIcon = {
      albumCover = { useAsIcon = false; radius = 8; };
      icon = "view-media-track";
    };
    playbackSource = "auto";    # auto, mpris2
    musicControls.showPlaybackControls = true;
    songText = {
      displayInSeparateLines = true;
      maximumWidth = 640;
      scrolling = { behavior = "alwaysScroll"; speed = 3; };
    };
  };
}
```

### systemMonitor
```nix
{ systemMonitor = {
    displayStyle = "org.kde.ksysguard.barchart"; # barchart, piechart, linechart, textonly, facegrid
    sensors = [
      { name = "cpu/all/usage"; color = "85,170,255"; label = "CPU"; }
      { name = "memory/physical/usedPercent"; color = "255,85,85"; label = "RAM"; }
    ];
    totalSensors = [ "cpu/all/usage" ];
    textOnlySensors = [ "cpu/all/usage" "memory/physical/usedPercent" ];
  };
}
```

## Desktop Widgets

```nix
desktop.widgets = [
  {
    plasmusicToolbar = {
      position = { horizontal = 51; vertical = 100; };
      size = { width = 250; height = 250; };
    };
  }
  {
    digitalClock = {
      position = { horizontal = 100; vertical = 300; };
      size = { width = 400; height = 200; };
      time.format = "24h";
    };
  }
];
```

Desktop widgets must include `position` (horizontal/vertical) and `size` (width/height).

## Desktop Mouse Actions and Icons

```nix
desktop = {
  icons = {
    arrangement = "name";     # manual, name, size, date, type
    alignment = "left";       # left, top (and others)
    lockInPlace = false;
    sorting = {
      mode = "name";
      descending = false;
      foldersFirst = true;
    };
  };
  mouseActions = {
    leftClick = "applicationLauncher";
    middleClick = "paste";
    rightClick = "contextMenu";
    # Options: applicationLauncher, contextMenu, paste, switchActivity, switchWindow
  };
};
```

## Common Panel Layouts

### Basic bottom taskbar
```nix
panels = [{
  location = "bottom";
  widgets = [
    { kickoff.icon = "nix-snowflake-white"; }
    { iconTasks.launchers = [
        "applications:org.kde.dolphin.desktop"
        "applications:org.kde.konsole.desktop"
      ];
    }
    "org.kde.plasma.marginsseparator"
    { systemTray.items.shown = [ "org.kde.plasma.volume" "org.kde.plasma.networkmanagement" ]; }
    { digitalClock.time.format = "24h"; }
  ];
}];
```

### macOS-style top bar + dock
```nix
panels = [
  {
    location = "top";
    height = 26;
    widgets = [
      { kickoff.icon = "nix-snowflake-white"; }
      "org.kde.plasma.appmenu"
      "org.kde.plasma.panelspacer"
      { digitalClock.time.format = "24h"; }
      "org.kde.plasma.panelspacer"
      { systemTray = {}; }
    ];
  }
  {
    location = "bottom";
    hiding = "dodgewindows";
    alignment = "center";
    lengthMode = "fit";
    widgets = [
      { iconTasks.launchers = [
          "applications:org.kde.dolphin.desktop"
          "applications:org.kde.konsole.desktop"
          "applications:firefox.desktop"
        ];
      }
    ];
  }
];
```
