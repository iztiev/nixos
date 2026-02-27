---
name: plasma-manager
description: Use when configuring KDE Plasma 6 desktop in home-manager, including panels, widgets, shortcuts, themes, window rules, input devices, and KDE application settings via plasma-manager
license: MIT
metadata:
  author: iztiev
  version: "1.0.0"
---

# Configuring KDE Plasma 6 with plasma-manager

Declaratively configure KDE Plasma 6 desktop environment in NixOS via home-manager using the plasma-manager module.

## Core Principle

**plasma-manager provides three configuration levels:** high-level semantic options (workspace, panels, widgets), mid-level shortcuts, and low-level direct config file access (`configFile`, `dataFile`, `file`). Prefer the highest level available; fall back to `configFile` for anything not covered.

## When to Use

- Configuring KDE Plasma themes, colors, cursors, wallpapers
- Setting up panels with widgets (taskbar, system tray, clock, etc.)
- Defining global keyboard shortcuts or custom hotkeys
- Configuring input devices (keyboard layouts, mouse, touchpad)
- Setting KWin options (virtual desktops, effects, tiling, window rules)
- Configuring KDE apps (Konsole profiles, Kate, Okular)
- Power management and session settings
- Any KDE Plasma desktop configuration via Nix

**Don't use for:**
- COSMIC desktop configuration (different module system)
- GNOME/Hyprland/Sway configuration
- System-level display manager (SDDM) settings (requires NixOS module, not home-manager)

## Quick Reference

| Topic | Rule File |
|-------|-----------|
| Flake integration setup | [integration](rules/integration.md) |
| Workspace: themes, colors, wallpaper | [workspace](rules/workspace.md) |
| Panels and widgets | [panels-widgets](rules/panels-widgets.md) |
| Input: keyboard, mouse, touchpad | [input](rules/input.md) |
| Shortcuts and hotkeys | [shortcuts-hotkeys](rules/shortcuts-hotkeys.md) |
| KWin: virtual desktops, effects, tiling | [kwin](rules/kwin.md) |
| Fonts | [fonts](rules/fonts.md) |
| Power management and session | [power-session](rules/power-session.md) |
| Window rules | [window-rules](rules/window-rules.md) |
| KDE application config | [apps](rules/apps.md) |
| Low-level config file access | [files-lowlevel](rules/files-lowlevel.md) |
| Common mistakes and troubleshooting | [common-mistakes](rules/common-mistakes.md) |

## This Repository's Setup

plasma-manager is already integrated in `flake.nix`:
- Input: `plasma-manager` with nixpkgs and home-manager follows
- Shared module: `plasma-manager.homeModules.plasma-manager` in `home-manager.sharedModules`
- Configuration goes in `home-manager/home.nix` or a dedicated module under `modules/home-manager/`

To add Plasma configuration:
```nix
# In home-manager/home.nix or imported module
programs.plasma = {
  enable = true;
  # ... configuration options
};
```

## Configuration Levels

| Level | Use For | Example |
|-------|---------|---------|
| **High-level** | Semantic settings with validation | `workspace.colorScheme = "BreezeDark"` |
| **Mid-level** | Keyboard shortcuts by group | `shortcuts.kwin."Switch Window Down" = "Meta+J"` |
| **Low-level** | Any KDE INI setting directly | `configFile.kwinrc.Desktops.Number = 8` |

## Available Widget Types (for panels/desktop)

High-level (with typed options): `kickoff`, `iconTasks`, `digitalClock`, `systemTray`, `pager`, `battery`, `panelSpacer`, `appMenu`, `keyboardLayout`, `applicationTitleBar`, `plasmusicToolbar`, `panelColorizer`, `kickerDash`, `kicker`, `systemMonitor`

Raw widget names: `"org.kde.plasma.kickoff"`, `"org.kde.plasma.icontasks"`, `"org.kde.plasma.marginsseparator"`, etc.

## Key Config Files Written

| Config File | Controls |
|-------------|----------|
| kdeglobals | Global KDE settings, themes, fonts |
| kwinrc | Window manager, virtual desktops, effects |
| plasmarc | Plasma shell theme |
| kcminputrc | Input devices (mouse, touchpad) |
| kxkbrc | Keyboard layouts |
| kglobalshortcutsrc | Global keyboard shortcuts |
| kscreenlockerrc | Screen locker |
| powerdevilrc | Power management |

## How to Use

Read individual rule files for detailed options and examples:

```
rules/integration.md       # Adding plasma-manager to your flake
rules/workspace.md         # Themes, wallpapers, cursors
rules/panels-widgets.md    # Panel layout and widget config
rules/shortcuts-hotkeys.md # Keyboard shortcuts
rules/kwin.md              # Window manager settings
rules/files-lowlevel.md    # Direct config file access
rules/common-mistakes.md   # Pitfalls and debugging
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
