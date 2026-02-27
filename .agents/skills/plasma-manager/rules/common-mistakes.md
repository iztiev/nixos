# Common Mistakes and Troubleshooting

## Mistake 1: Changes Not Applying After Rebuild

**Symptom:** Rebuilt successfully but KDE still shows old settings.

**Causes and fixes:**
- **Panel/widget changes** require logout and login (desktop scripts run at Plasma startup)
- **Theme changes** applied via `plasma-apply-*` tools only on first login after change
- **Some settings** require `qdbus6 org.kde.KWin /KWin reconfigure` to reload KWin

```bash
# After rebuild, try:
qdbus6 org.kde.KWin /KWin reconfigure  # Reload KWin settings
# If that doesn't work, log out and log back in
```

## Mistake 2: Mixing High-Level and Low-Level for Same Setting

**Symptom:** Settings conflict or override each other unpredictably.

```nix
# ❌ WRONG: Both set the same thing
kwin.virtualDesktops.number = 4;
configFile.kwinrc.Desktops.Number = 8;  # Conflicts!

# ✅ CORRECT: Use one level only
kwin.virtualDesktops.number = 4;
```

**Rule:** If a high-level option exists, use it. Only use `configFile` for settings without high-level equivalents.

## Mistake 3: Widget Config Key Casing

**Symptom:** Widget settings ignored.

Widget config keys in `config = { Group = { key = value; }; }` must match KDE's exact casing. The group is typically capitalized (`General`), keys vary.

```nix
# ❌ WRONG
config = { general = { Icon = "nix-snowflake"; }; };

# ✅ CORRECT
config = { General = { icon = "nix-snowflake"; }; };
```

Check `~/.config/plasma-org.kde.plasma.desktop-appletsrc` for correct key names.

## Mistake 4: Panel Widget Order Matters

**Symptom:** Widgets appear in wrong order.

Widgets are added to the panel in array order. The first widget is leftmost (or topmost for vertical panels).

```nix
# Widgets appear left-to-right in this order:
widgets = [
  { kickoff = {}; }           # Far left
  { iconTasks = {}; }         # Next
  "org.kde.plasma.panelspacer" # Flexible space
  { systemTray = {}; }        # Near right
  { digitalClock = {}; }      # Far right
];
```

## Mistake 5: Forgetting enable = true

**Symptom:** No plasma-manager settings applied at all.

```nix
# ❌ WRONG: Missing enable
programs.plasma = {
  workspace.colorScheme = "BreezeDark";
};

# ✅ CORRECT
programs.plasma = {
  enable = true;
  workspace.colorScheme = "BreezeDark";
};
```

## Mistake 6: overrideConfig Wiping Settings

**Symptom:** Manual KDE settings disappear after rebuild.

```nix
programs.plasma = {
  overrideConfig = true;  # WARNING: Resets EVERYTHING not in Nix config
};
```

Only use `overrideConfig = true` if you're fully declarative. Otherwise, unspecified settings revert to defaults on every rebuild.

**Safer alternative:** Use `resetFiles` to only reset specific config files:
```nix
programs.plasma.resetFiles = [ "kwinrc" ];  # Only reset KWin settings
```

## Mistake 7: Shortcut Group Names

**Symptom:** Shortcuts don't apply.

Shortcut group names must match KDE's internal component names exactly:

```nix
# ❌ WRONG: Incorrect group name
shortcuts."KWin" = { "Window Close" = "Meta+Q"; };

# ✅ CORRECT: Use lowercase "kwin"
shortcuts.kwin = { "Window Close" = "Meta+Q"; };
```

Common group names: `kwin`, `ksmserver`, `plasmashell`, `kmix`, `mediacontrol`, `org_kde_powerdevil`

For service shortcuts: `"services/org.kde.spectacle.desktop"`

## Mistake 8: Keyboard Layout Without switchMode

**Symptom:** Multiple layouts defined but can't switch between them.

```nix
# ❌ Incomplete: No way to switch
input.keyboard.layouts = [
  { layout = "us"; }
  { layout = "ru"; }
];

# ✅ Complete: Add switch shortcut
input.keyboard.layouts = [
  { layout = "us"; }
  { layout = "ru"; }
];
input.keyboard.switchMode = "global";
# Also add a shortcut to switch:
shortcuts.kded6."Switch Keyboard Layout" = "Meta+Space";
```

## Debugging Tips

### Check what plasma-manager generates

```bash
# View the home-manager activation script
cat /nix/store/*-home-manager-files/activate

# Check generated config files
ls -la ~/.config/  # After rebuild + relogin
```

### View current KDE config

```bash
# Read current KDE settings
cat ~/.config/kwinrc
cat ~/.config/kdeglobals
cat ~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

### Convert current config to Nix

```bash
nix run github:nix-community/plasma-manager -- rc2nix -n
```

### Build without switching (dry run)

```bash
nixos-rebuild build --flake ~/nixos#rhea
# Check for errors without applying
```

### Known Limitations

- Some keybindings can't be set (Ctrl+Alt+T, Print) if system captures them first
- rc2nix output is for `configFile` module; manually convert to high-level options where possible
- SDDM configuration requires NixOS module (`services.displayManager.sddm`), not plasma-manager
- Real-time updates without logout not fully supported for all settings
- Panel configuration is applied via desktop scripts that run at login
