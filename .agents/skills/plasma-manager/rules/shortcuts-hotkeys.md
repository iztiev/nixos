# Shortcuts and Hotkeys

## Global Shortcuts (`shortcuts`)

Configure existing KDE shortcut actions. Written to `kglobalshortcutsrc`.

```nix
shortcuts = {
  # Group name = KDE component
  kwin = {
    "Switch Window Down" = "Meta+J";
    "Switch Window Left" = "Meta+H";
    "Switch Window Right" = "Meta+L";
    "Switch Window Up" = "Meta+K";
    "Expose" = "Meta+,";
    "Switch One Desktop Down" = "Meta+Ctrl+J";
    "Switch One Desktop Up" = "Meta+Ctrl+K";
    "Window Maximize" = "Meta+Up";
    "Window Minimize" = "Meta+Down";
    "Window Close" = "Meta+Q";
    "Window Quick Tile Left" = "Meta+Left";
    "Window Quick Tile Right" = "Meta+Right";
    "Kill Window" = "Meta+Ctrl+Escape";
  };

  ksmserver = {
    "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];  # Multiple bindings
  };

  plasmashell = {
    "show-on-mouse-pos" = "Meta+V";    # Clipboard popup
    "manage activities" = "Meta+A";
  };

  # For service shortcuts, use the desktop file path
  "services/org.kde.spectacle.desktop" = {
    "_launch" = "Print";
  };

  # KWin Wayland-specific
  kwin_wayland = {
    "Switch to Desktop 1" = "Meta+1";
    "Switch to Desktop 2" = "Meta+2";
  };
};
```

### Multiple keybindings for one action

Use a list:
```nix
"Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
```

### Disable a shortcut

Set to empty string or "none":
```nix
"some action" = "";
# or
"some action" = "none";
```

## Common Shortcut Groups

| Group | Controls |
|-------|----------|
| `kwin` | Window manager actions |
| `kwin_wayland` | Wayland-specific window actions |
| `ksmserver` | Session manager (lock, logout) |
| `plasmashell` | Plasma shell (clipboard, activities, widgets) |
| `org_kde_powerdevil` | Power management shortcuts |
| `kmix` | Volume control |
| `mediacontrol` | Media playback |
| `kded6` | KDE daemon services |

## Custom Hotkeys (`hotkeys`)

Create new hotkeys that run custom commands. Creates desktop entries + shortcut bindings.

```nix
hotkeys.commands = {
  "launch-konsole" = {
    name = "Launch Konsole";
    comment = "Open terminal";
    key = "Meta+Alt+K";
    command = "konsole";
  };

  "screenshot-region" = {
    name = "Screenshot Region";
    key = "Meta+Shift+S";
    command = "spectacle -r";
  };

  # With systemd logging
  "launch-browser" = {
    name = "Launch Browser";
    key = "Meta+B";
    command = "firefox";
    logs = {
      enabled = true;
      identifier = "plasma-launch-firefox";
    };
  };

  # Multiple keybindings
  "terminal" = {
    name = "Terminal";
    keys = [ "Meta+Return" "Ctrl+Alt+T" ];  # Note: keys (plural)
    command = "konsole";
  };
};
```

### Hotkey options

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Display name (required) |
| `comment` | string | Description (optional) |
| `key` | string | Single keybinding |
| `keys` | list of strings | Multiple keybindings (use instead of `key`) |
| `command` | string | Shell command to execute (required) |
| `logs.enabled` | bool | Route output to systemd journal |
| `logs.identifier` | string | Journal identifier |
| `logs.extraArgs` | string | Extra args for systemd-cat |

## Spectacle Shortcuts

Dedicated module for screenshot/recording shortcuts:

```nix
spectacle.shortcuts = {
  captureActiveWindow = "Meta+Print";
  captureCurrentMonitor = "Print";
  captureEntireDesktop = "Shift+Print";
  captureRectangularRegion = "Meta+Shift+Print";
  captureWindowUnderCursor = "Meta+Ctrl+Print";
  launch = "Print";
  launchWithoutCapturing = "";
  recordRegion = "Meta+Shift+R";
  recordScreen = "Meta+Alt+R";
  recordWindow = "Meta+Ctrl+R";
};
```

## KRunner Shortcuts

```nix
krunner = {
  position = "center";               # top, center
  activateWhenTypingOnDesktop = true;
  historyBehavior = "enableSuggestions"; # disabled, enableSuggestions, enableAutoComplete
  shortcuts = {
    launch = "Alt+F2";
    runCommandOnClipboard = "Alt+Shift+F2";
  };
};
```
