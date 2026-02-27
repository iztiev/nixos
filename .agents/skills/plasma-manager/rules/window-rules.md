# Window Rules

KWin window-specific rules. Written to `kwinrulesrc`.

## Structure

```nix
window-rules = [
  {
    description = "Rule Name";    # Required: human-readable description

    match = {
      # Match criteria (all are optional, combined with AND)
      window-class = {
        value = "firefox";
        type = "substring";        # exact, substring, regex
      };
      window-role = {
        value = "browser";
        type = "exact";
      };
      title = {
        value = ".*YouTube.*";
        type = "regex";
        match-whole = true;        # Match entire title
      };
      machine = "localhost";       # Machine name
      window-types = [ "normal" ]; # Window type filter
    };

    apply = {
      # Properties to apply (see below)
    };
  }
];
```

## Match Criteria

### Simple string match
```nix
match.window-class = {
  value = "dolphin";
  type = "substring";    # exact, substring, regex
};
```

### Window types
```nix
match.window-types = [ "normal" "dialog" "utility" "toolbar" "splash" "desktop" "dock" "popup" "notification" "tooltip" "override" ];
```

## Apply Properties

Each property can be a simple value (defaults to "apply-initially") or a submodule with explicit apply mode.

### Apply modes
- `"do-not-affect"` - Don't apply this rule
- `"apply-initially"` - Apply once when window opens (default)
- `"remember"` - Remember changes made by user
- `"force"` - Force and prevent changes

### Boolean properties
```nix
apply = {
  noborder = { value = true; apply = "force"; };
  skiptaskbar = { value = true; apply = "force"; };
  skippager = true;                    # Short form, uses "apply-initially"
  above = { value = true; apply = "force"; };
  below = false;
  fullscreen = true;
  maximizehoriz = true;
  maximizevert = true;
  minimize = false;
  shade = false;
  closeable = true;
  autogroup = false;
};
```

### Geometry properties
```nix
apply = {
  position = { value = { x = 100; y = 100; }; apply = "remember"; };
  size = { value = { width = 800; height = 600; }; apply = "initially"; };
  screen = { value = 0; apply = "force"; };           # Monitor index
  desktops = { value = "desktop-1"; apply = "force"; }; # Virtual desktop
  activity = { value = "activity-id"; apply = "force"; };
};
```

### Opacity
```nix
apply = {
  opacityactive = { value = 90; apply = "force"; };    # 0-100
  opacityinactive = { value = 80; apply = "force"; };
};
```

## Complete Examples

### Force borderless maximized Dolphin
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
      maximizehoriz = true;
      maximizevert = true;
    };
  }
];
```

### Picture-in-picture always on top
```nix
{
  description = "PiP Always on Top";
  match = {
    title = { value = "Picture-in-Picture"; type = "exact"; };
    window-types = [ "normal" ];
  };
  apply = {
    above = { value = true; apply = "force"; };
    skiptaskbar = { value = true; apply = "force"; };
    skippager = { value = true; apply = "force"; };
  };
}
```

### Firefox on specific desktop
```nix
{
  description = "Firefox on Desktop 2";
  match = {
    window-class = { value = "firefox"; type = "exact"; };
  };
  apply = {
    desktops = { value = "desktop-2"; apply = "initially"; };
  };
}
```
