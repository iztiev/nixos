# Low-Level Config File Access

The `files` module provides direct access to KDE INI configuration files. Use when high-level options don't cover your needs.

## Three File Scopes

### configFile (XDG_CONFIG_HOME / ~/.config/)
```nix
configFile = {
  # Simple values
  "kwinrc"."Desktops"."Number" = 4;
  "kdeglobals"."General"."BrowserApplication" = "firefox.desktop";
  "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;

  # Nested groups use / separator
  "kscreenlockerrc"."Greeter/Wallpaper/org.kde.potd/General"."Provider" = "bing";
};
```

### dataFile (XDG_DATA_HOME / ~/.local/share/)
```nix
dataFile = {
  "some-data-file"."Group"."Key" = "value";
};
```

### file (HOME / ~/)
```nix
file = {
  ".some-dotfile"."Group"."Key" = "value";
};
```

## Value Types

### Basic (most common)
```nix
configFile.kwinrc.Desktops.Number = 4;         # int
configFile.kwinrc.Compositing.GLCore = true;    # bool
configFile.kwinrc.Compositing.Backend = "OpenGL"; # string
configFile.kdeglobals.General.SomeFloat = 1.5;  # float
configFile.kwinrc.Some.Key = null;              # delete the key
```

### Advanced (with modifiers)
```nix
configFile.kwinrc.Desktops.Number = {
  value = 8;
  immutable = true;       # Prevent changes via KDE Settings GUI (adds [$i] suffix)
};

configFile.somefile.Group.Key = {
  value = "$HOME/Documents";
  shellExpand = true;     # Expand shell variables (adds [$e] suffix)
};

configFile.somefile.Group.Key = {
  value = "preserved";
  persistent = true;      # Don't reset in overrideConfig mode
};

configFile.somefile.Group.Key = {
  value = "special;chars,here";
  escapeValue = true;     # Apply KDE escape format (\; \, etc.)
};
```

## Global Options

### overrideConfig
```nix
programs.plasma = {
  overrideConfig = true;   # Reset ALL unspecified settings to defaults
  # WARNING: This deletes any settings not declared in your Nix config
};
```

### resetFiles
```nix
programs.plasma = {
  resetFiles = [ "kwinrc" "plasmarc" ];           # Delete these before applying
  resetFilesExclude = [ "kdeglobals" ];            # Never delete these
};
```

### immutableByDefault
```nix
programs.plasma = {
  immutableByDefault = true;  # Make ALL keys immutable (prevents GUI changes)
};
```

## Nested Groups

KDE config files support nested groups. Use `/` as separator:

```nix
# Produces:
# [Greeter]
# [Wallpaper]
# [org.kde.potd]
# [General]
# Provider=bing

configFile.kscreenlockerrc."Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
```

## Common Config Files Reference

| File | Purpose | Key Groups |
|------|---------|------------|
| `kdeglobals` | Global KDE settings | General, KDE, Icons |
| `kwinrc` | Window manager | Compositing, Desktops, Windows, org.kde.kdecoration2, NightColor |
| `plasmarc` | Plasma shell | Theme |
| `kcminputrc` | Input devices | Mouse, Touchpad, Libinput |
| `kxkbrc` | Keyboard layouts | Layout |
| `kglobalshortcutsrc` | Shortcuts | Per-component groups |
| `kscreenlockerrc` | Screen locker | Daemon, Greeter |
| `powerdevilrc` | Power management | AC, Battery, LowBattery |
| `ksmserverrc` | Session | General |
| `krunnerrc` | KRunner | General, Plugins |
| `baloofilerc` | File indexing | Basic Settings |
| `dolphinrc` | File manager | General, CompactMode, DetailsMode |
| `kwinrulesrc` | Window rules | Per-rule numbered groups |

## Example: Disable Baloo file indexing

```nix
configFile.baloofilerc."Basic Settings"."Indexing-Enabled" = false;
```

## Example: KWin compositing

```nix
configFile.kwinrc.Compositing = {
  Backend = "OpenGL";
  GLCore = true;
  LatencyPolicy = "Low";
  MaxFPS = 144;
  AnimationSpeed = 3;
};
```

## Example: Custom titlebar buttons

```nix
configFile.kwinrc."org.kde.kdecoration2" = {
  ButtonsOnLeft = "SF";    # S=OnAllDesktops, F=KeepAbove
  ButtonsOnRight = "HIAX"; # H=Help, I=Minimize, A=Maximize, X=Close
};
```
