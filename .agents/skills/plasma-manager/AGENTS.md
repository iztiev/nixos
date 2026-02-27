# KDE Plasma 6 Configuration with plasma-manager

Complete reference for declaratively configuring KDE Plasma 6 desktop in NixOS via home-manager using the plasma-manager module.

## Table of Contents

- [Overview](#overview)
- [Integration](#integration)
- [Workspace: Themes, Colors, Wallpaper](#workspace)
- [Panels and Widgets](#panels-and-widgets)
- [Input: Keyboard, Mouse, Touchpad](#input)
- [Shortcuts and Hotkeys](#shortcuts-and-hotkeys)
- [KWin: Window Manager](#kwin)
- [Fonts](#fonts)
- [Power Management and Session](#power-and-session)
- [Window Rules](#window-rules)
- [KDE Applications](#kde-applications)
- [Low-Level Config File Access](#low-level-config-file-access)
- [Startup Scripts](#startup-scripts)
- [Common Mistakes](#common-mistakes)

---

## Overview

plasma-manager provides three configuration levels for KDE Plasma 6:

| Level | Use For | Example |
|-------|---------|---------|
| **High-level** | Semantic settings with type validation | `workspace.colorScheme = "BreezeDark"` |
| **Mid-level** | Keyboard shortcuts by component group | `shortcuts.kwin."Window Close" = "Meta+Q"` |
| **Low-level** | Any KDE INI setting directly | `configFile.kwinrc.Desktops.Number = 8` |

**Rule:** Prefer the highest level available. Fall back to `configFile` for anything not covered by a dedicated option.

### Key Config Files

| File | Controls |
|------|----------|
| kdeglobals | Global themes, fonts, behavior |
| kwinrc | Window manager, compositing, virtual desktops |
| plasmarc | Plasma shell theme |
| kcminputrc | Mouse and touchpad |
| kxkbrc | Keyboard layouts |
| kglobalshortcutsrc | Global keyboard shortcuts |
| kscreenlockerrc | Screen locker |
| powerdevilrc | Power management |
| ksmserverrc | Session manager |

---

## Integration

### This Repository's Setup

Already integrated in `flake.nix`:
- Input: `plasma-manager` (line 22-27) with nixpkgs and home-manager follows
- Shared module: `plasma-manager.homeModules.plasma-manager` (line 69)

To configure, add to `home-manager/home.nix` or a module:
```nix
programs.plasma = {
  enable = true;
  # ... options
};
```

### Adding to a New Flake

```nix
inputs = {
  plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};

# In the home-manager module block:
home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
```

### rc2nix Tool

Convert existing KDE config to Nix:
```bash
nix run github:nix-community/plasma-manager -- rc2nix -n
```

---

## Workspace

All options under `programs.plasma.workspace`.

### Themes and Appearance

```nix
workspace = {
  lookAndFeel = "org.kde.breezedark.desktop";  # Global theme
  theme = "breeze-dark";           # Plasma style
  colorScheme = "BreezeDark";      # Color scheme
  widgetStyle = "breeze";          # Qt widget style
  iconTheme = "Papirus-Dark";
  soundTheme = "ocean";
};
```

### Cursor

```nix
workspace.cursor = {
  theme = "Bibata-Modern-Ice";
  size = 24;
};
```

### Wallpaper (4 modes, mutually exclusive)

```nix
# Static
workspace.wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";

# Slideshow
workspace.wallpaperSlideShow = { path = "/path/to/folder"; interval = 300; };

# Picture of the Day
workspace.wallpaperPictureOfTheDay = { provider = "bing"; };
# Providers: apod, bing, flickr, natgeo, noaa, wcpotd, epod, simonstalenhag

# Plain color
workspace.wallpaperPlainColor = "40,42,54";
```

Fill mode: `workspace.wallpaperFillMode = "preserveAspectCrop";`
Options: stretch, preserveAspectFit, preserveAspectCrop, tile, pad

### Window Decorations

```nix
workspace.windowDecorations = { library = "org.kde.breeze"; theme = "Breeze"; };
```

### Splash Screen

```nix
workspace.splashScreen = { engine = "none"; theme = "None"; };
```

### Behavior

```nix
workspace.clickItemTo = "open";            # open (single-click), select (double-click)
workspace.enableMiddleClickPaste = true;
workspace.tooltipDelay = 700;
```

---

## Panels and Widgets

### Panel Definition

```nix
panels = [
  {
    location = "bottom";       # top, bottom, left, right, floating
    height = 44;
    alignment = "center";      # left, center, right
    lengthMode = "fill";       # fill, fit, custom
    floating = true;
    hiding = "none";           # none, autohide, dodgewindows, normalpanel, windowsgobelow
    opacity = "adaptive";      # adaptive, opaque, translucent
    screen = 0;                # Monitor index, [0 1], or "all"
    widgets = [ ... ];
  }
];
```

### Widget Specification (3 ways)

```nix
widgets = [
  # 1. Simple string (default config)
  "org.kde.plasma.panelspacer"

  # 2. Name + raw config
  { name = "org.kde.plasma.kickoff"; config = { General.icon = "nix-snowflake-white"; }; }

  # 3. High-level typed options (preferred)
  { kickoff.icon = "nix-snowflake-white"; }
];
```

### Available High-Level Widgets

**kickoff** (App Launcher):
```nix
{ kickoff = { icon = "nix-snowflake-white"; sortAlphabetically = true; compactMode = false;
    sidebarPosition = "left"; favoritesDisplayMode = "grid"; }; }
```

**iconTasks** (Task Manager):
```nix
{ iconTasks = { launchers = [ "applications:org.kde.dolphin.desktop" "applications:org.kde.konsole.desktop" ]; }; }
```

**digitalClock**:
```nix
{ digitalClock = { time.format = "24h"; time.showSeconds = "never"; date.enable = true;
    date.format = "isoDate"; calendar.firstDayOfWeek = "monday"; }; }
```

**systemTray**:
```nix
{ systemTray.items = { shown = [ "org.kde.plasma.battery" ]; hidden = [ "org.kde.plasma.clipboard" ]; }; }
```

**Other widgets:** `pager`, `battery`, `panelSpacer`, `appMenu`, `keyboardLayout`, `applicationTitleBar`, `plasmusicToolbar`, `panelColorizer`, `systemMonitor`, `kickerDash`, `kicker`

### Desktop Widgets

```nix
desktop.widgets = [
  { plasmusicToolbar = {
      position = { horizontal = 51; vertical = 100; };
      size = { width = 250; height = 250; };
    };
  }
];
```

### Desktop Mouse Actions

```nix
desktop.mouseActions = { leftClick = "applicationLauncher"; rightClick = "contextMenu"; };
desktop.icons = { arrangement = "name"; lockInPlace = false; sorting.foldersFirst = true; };
```

---

## Input

### Keyboard

```nix
input.keyboard = {
  layouts = [
    { layout = "us"; }
    { layout = "ru"; }
    { layout = "de"; variant = "nodeadkeys"; displayName = "DE"; }
  ];
  switchMode = "global";  # global, desktop, winClass, window
  numlock = "on";          # on, off, unchanged
};
```

### Mouse

```nix
input.mice = [{
  name = "Logitech G Pro";
  pointerSpeed = 0.0;               # -1.0 to 1.0
  accelerationProfile = "none";      # none (flat), default (adaptive)
  naturalScroll = false;
  leftHanded = false;
}];
```

### Touchpad

```nix
input.touchpads = [{
  name = "ELAN Touchpad";
  naturalScroll = true;
  tapToClick = true;
  disableWhileTyping = true;
  pointerSpeed = 0.0;
  accelerationProfile = "default";
  rightClick = "twoFingers";
  scrollMethod = "twoFingers";
}];
```

---

## Shortcuts and Hotkeys

### Global Shortcuts

```nix
shortcuts = {
  kwin = {
    "Switch Window Down" = "Meta+J";
    "Switch Window Up" = "Meta+K";
    "Window Close" = "Meta+Q";
    "Expose" = "Meta+,";
  };
  ksmserver = {
    "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];  # Multiple bindings
  };
  plasmashell = { "show-on-mouse-pos" = "Meta+V"; };
};
```

Groups: `kwin`, `kwin_wayland`, `ksmserver`, `plasmashell`, `kmix`, `mediacontrol`, `org_kde_powerdevil`, `kded6`

### Custom Hotkeys

```nix
hotkeys.commands."launch-konsole" = {
  name = "Launch Konsole";
  key = "Meta+Alt+K";          # Single binding
  # keys = [ "Meta+Return" ];  # Multiple bindings
  command = "konsole";
};
```

### Spectacle Shortcuts

```nix
spectacle.shortcuts = {
  captureRectangularRegion = "Meta+Shift+Print";
  recordRegion = "Meta+Shift+R";
  launch = "Print";
};
```

### KRunner

```nix
krunner = { position = "center"; activateWhenTypingOnDesktop = true;
  historyBehavior = "enableSuggestions"; };
```

---

## KWin

### Titlebar Buttons

```nix
kwin.titlebarButtons = {
  left = [ "on-all-desktops" "keep-above-windows" ];
  right = [ "help" "minimize" "maximize" "close" ];
};
```

Buttons: `more-window-actions`, `application-menu`, `on-all-desktops`, `minimize`, `maximize`, `close`, `help`, `shade`, `keep-below-windows`, `keep-above-windows`, `spacer`

### Virtual Desktops

```nix
kwin.virtualDesktops = { number = 4; names = [ "Main" "Dev" "Web" "Chat" ]; rows = 1; };
```

### Edge Barriers

```nix
kwin.edgeBarrier = 0;       # 0 disables
kwin.cornerBarrier = false;
```

### Effects

```nix
kwin.effects = {
  blur.enable = true;
  desktopSwitching.animation = "slide";   # slide, fade, windowShuffle
  minimization.animation = "magiclamp";   # magiclamp, squash
  shakeCursor.enable = true;
  wobblyWindows.enable = false;
};
```

### Tiling and Scripts

```nix
kwin.scripts.polonium.enable = true;
kwin.tilingManager = true;
```

### Compositing (via configFile)

```nix
configFile.kwinrc.Compositing = {
  Backend = "OpenGL"; GLCore = true; LatencyPolicy = "Low";
  MaxFPS = 144; AnimationSpeed = 3;
};
```

---

## Fonts

```nix
fonts = {
  general   = { family = "Noto Sans"; pointSize = 10; };
  monospace = { family = "JetBrains Mono"; pointSize = 10; };
  small     = { family = "Noto Sans"; pointSize = 8; };
  toolbar   = { family = "Noto Sans"; pointSize = 10; };
  menu      = { family = "Noto Sans"; pointSize = 10; };
  windowTitle = { family = "Noto Sans"; pointSize = 10; weight = "bold"; };
  taskbar   = { family = "Noto Sans"; pointSize = 10; };
};
```

Font properties: `family`, `pointSize`/`pixelSize`, `weight` (thin..black or 1-1000), `style` (normal/italic/oblique), `styleHint` (serif/sans/monospace), `underline`, `strikeOut`, `styleStrategy`

---

## Power and Session

### PowerDevil

```nix
powerdevil = {
  AC = {
    powerButtonAction = "lockScreen";  # nothing, sleep, hibernate, shutDown, lockScreen, turnOffScreen
    autoSuspend = { action = "sleep"; idleTimeout = 600; };
    whenLaptopLidClosed = "sleep";
    turnOffDisplay = { idleTimeout = 300; idleTimeoutWhenLocked = 60; };
  };
  battery = {
    powerButtonAction = "sleep";
    whenSleepingEnter = "standbyThenHibernate";
  };
  lowBattery = { whenLaptopLidClosed = "hibernate"; };
};
```

### Screen Locker

```nix
kscreenlocker = {
  autoLock = true; lockOnResume = true; timeout = 10;
  appearance.wallpaper = "/path/to/image.png";
};
```

### Session

```nix
session = {
  general.askForConfirmationOnLogout = true;
  sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
};
```

---

## Window Rules

```nix
window-rules = [
  {
    description = "Dolphin Maximized";
    match = {
      window-class = { value = "dolphin"; type = "substring"; };
      window-types = [ "normal" ];
    };
    apply = {
      noborder = { value = true; apply = "force"; };
      maximizehoriz = true;  # Short form, defaults to "apply-initially"
      maximizevert = true;
    };
  }
];
```

Match types: `exact`, `substring`, `regex`
Apply modes: `do-not-affect`, `apply-initially` (default), `remember`, `force`

---

## KDE Applications

### Konsole

```nix
apps.konsole = {
  defaultProfile = "MyProfile";
  profiles.MyProfile = {
    colorScheme = "Breeze";
    font = { family = "JetBrains Mono"; pointSize = 12; };
  };
};
```

### Kate

```nix
apps.kate.editor = {
  indent = { width = 4; replaceWithSpaces = true; };
  font = { family = "JetBrains Mono"; pointSize = 12; };
};
```

### Any App (via configFile)

```nix
configFile.dolphinrc.General.ShowFullPath = true;
```

---

## Low-Level Config File Access

### Three scopes

```nix
configFile."kwinrc"."Group"."Key" = value;     # ~/.config/
dataFile."somefile"."Group"."Key" = value;      # ~/.local/share/
file.".dotfile"."Group"."Key" = value;          # ~/
```

### Value modifiers

```nix
configFile.kwinrc.Desktops.Number = {
  value = 8;
  immutable = true;     # Prevents GUI changes ([$i])
};
configFile.somefile.Group.Key = {
  value = "$HOME/path";
  shellExpand = true;   # Expand shell vars ([$e])
};
```

### Global controls

```nix
programs.plasma.overrideConfig = true;       # Reset unspecified to defaults (destructive!)
programs.plasma.immutableByDefault = true;   # Lock all settings from GUI
programs.plasma.resetFiles = [ "kwinrc" ];   # Delete specific files before applying
```

### Nested groups (use / separator)

```nix
configFile.kscreenlockerrc."Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
```

---

## Startup Scripts

### Shell scripts (run at login)

```nix
startup.startupScript."my-script" = {
  text = ''
    echo "Hello from startup"
  '';
  priority = 0;        # 0-8, lower = earlier
  runAlways = false;    # true = run every login, false = once until changed
};
```

### Desktop scripts (Plasma JavaScript API)

```nix
startup.desktopScript."my-desktop-script" = {
  text = ''
    // Plasma Desktop Script (JavaScript)
    const desktop = workspace;
  '';
  priority = 0;
};
```

---

## Common Mistakes

1. **Missing `enable = true`** - No settings apply without it
2. **Changes not visible** - Panel/widget changes need logout/login
3. **Mixing levels** - Don't set same setting via high-level option AND configFile
4. **Widget config casing** - Group names capitalized (`General`), key names vary
5. **overrideConfig = true** - Destructive, resets ALL unspecified settings
6. **Wrong shortcut group** - Must match KDE internal names (lowercase `kwin`, not `KWin`)
7. **Panel widget order** - Array order = display order (left to right)

### Debugging

```bash
# Check current KDE config
cat ~/.config/kwinrc
cat ~/.config/plasma-org.kde.plasma.desktop-appletsrc

# Convert current settings to Nix
nix run github:nix-community/plasma-manager -- rc2nix -n

# Reload KWin without logout
qdbus6 org.kde.KWin /KWin reconfigure

# Build without switching
nixos-rebuild build --flake ~/nixos#rhea
```

### Limitations

- Some keybindings can't be set if system captures them first
- SDDM needs NixOS module (`services.displayManager.sddm`), not plasma-manager
- Real-time updates without logout not fully supported for all settings
- rc2nix generates `configFile` entries; manually convert to high-level options
