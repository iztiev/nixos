# KWin: Window Manager Configuration

All options under `programs.plasma.kwin`.

## Titlebar Buttons

```nix
kwin.titlebarButtons = {
  left = [ "on-all-desktops" "keep-above-windows" ];
  right = [ "help" "minimize" "maximize" "close" ];
};
```

**Available buttons:** `more-window-actions`, `application-menu`, `on-all-desktops`, `minimize`, `maximize`, `close`, `help`, `shade`, `keep-below-windows`, `keep-above-windows`, `spacer`

## Virtual Desktops

```nix
kwin.virtualDesktops = {
  number = 4;                          # Number of desktops
  names = [ "Main" "Dev" "Web" "Chat" ]; # Custom names (optional)
  rows = 1;                            # Grid rows (for pager layout)
};
```

## Edge and Corner Barriers

```nix
kwin = {
  edgeBarrier = 0;          # 0 disables edge barriers (pixels before cursor crosses screen edge)
  cornerBarrier = false;    # Disable corner barriers for multi-monitor
};
```

## Effects

```nix
kwin.effects = {
  blur.enable = true;             # Background blur
  cube.enable = false;            # Desktop cube (legacy)
  desktopSwitching.animation = "slide"; # slide, fade, windowShuffle
  dimAdminMode.enable = true;     # Dim screen when admin dialog appears
  dimInactive.enable = false;     # Dim inactive windows
  fallApart.enable = false;       # Windows fall apart when closed
  minimization.animation = "magiclamp"; # magiclamp, squash
  shakeCursor.enable = true;      # Enlarge cursor when shaken
  translucency.enable = false;    # Window translucency
  wobblyWindows.enable = false;   # Wobbly window effects
  slideBack.enable = true;        # Slide back windows
  snapHelper.enable = true;       # Show snap zones
};
```

## Tiling

```nix
kwin = {
  tilingManager = true;           # Enable tiling manager (Pluton)
  tilingLayouts = {
    "layout-name" = {
      # Custom tiling layout configuration
    };
  };
};
```

## KWin Scripts

```nix
kwin.scripts = {
  polonium.enable = true;         # Polonium tiling script
  # Other kwin scripts can be enabled here
};
```

## Night Light / Color

Configure via `configFile`:

```nix
configFile.kwinrc = {
  NightColor = {
    Active = true;
    NightTemperature = 3500;
    Mode = "Times";           # Times, Automatic, Location
    EveningBeginFixed = "1800";
    MorningBeginFixed = "0600";
  };
};
```

## Window Behavior

```nix
windows.allowWindowsToRememberPositions = true;
```

## Focus Policy (via configFile)

```nix
configFile.kwinrc.Windows = {
  FocusPolicy = "ClickToFocus";     # ClickToFocus, FocusFollowsMouse, FocusUnderMouse, FocusStrictlyUnderMouse
  NextFocusPrefersMouse = false;
  AutoRaise = false;
  AutoRaiseInterval = 750;
  DelayFocusInterval = 300;
  FocusStealingPreventionLevel = 1; # 0=None, 1=Low, 2=Medium, 3=High, 4=Extreme
};
```

## Multi-Monitor / Output Management

KWin output configuration is available for multi-monitor setups. Use `configFile` for advanced monitor settings:

```nix
configFile.kwinoutputconfigrc = {
  # Monitor-specific settings
};
```

## Common Config File Keys (kwinrc)

```nix
configFile.kwinrc = {
  Compositing = {
    Backend = "OpenGL";
    GLCore = true;
    LatencyPolicy = "Low";      # Low, Medium, High, ExtremelyLow
    MaxFPS = 144;
    RefreshRate = 144;
    AnimationSpeed = 3;          # 0=instant, 1=fast ... 6=slow
    WindowsBlockCompositing = true;
  };

  "org.kde.kdecoration2" = {
    BorderSize = "Normal";        # None, NoSides, Tiny, Normal, Large, VeryLarge, Huge, VeryHuge, Oversized
    BorderSizeAuto = false;
    ButtonsOnLeft = "SF";         # S=OnAllDesktops, F=KeepAbove, M=Menu, etc.
    ButtonsOnRight = "HIAX";      # H=Help, I=Minimize, A=Maximize, X=Close
    CloseOnDoubleClickOnMenu = false;
    ShowToolTips = true;
  };

  Desktops = {
    Number = { value = 4; immutable = true; };  # Prevent GUI changes
    Rows = 1;
  };
};
```
