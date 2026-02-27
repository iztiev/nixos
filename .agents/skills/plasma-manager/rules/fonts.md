# Fonts

All options under `programs.plasma.fonts`.

## Font Categories

```nix
fonts = {
  general = {
    family = "Noto Sans";
    pointSize = 10;
  };
  monospace = {
    family = "JetBrains Mono";
    pointSize = 10;
  };
  small = {
    family = "Noto Sans";
    pointSize = 8;
  };
  toolbar = {
    family = "Noto Sans";
    pointSize = 10;
  };
  menu = {
    family = "Noto Sans";
    pointSize = 10;
  };
  windowTitle = {
    family = "Noto Sans";
    pointSize = 10;
  };
  taskbar = {
    family = "Noto Sans";
    pointSize = 10;
  };
};
```

## Font Properties

Each font category accepts these properties:

| Property | Type | Description |
|----------|------|-------------|
| `family` | string | Font family name (required) |
| `pointSize` | int | Size in points (use this OR pixelSize) |
| `pixelSize` | int | Size in pixels (use this OR pointSize) |
| `weight` | int or string | Font weight |
| `style` | enum | `"normal"`, `"italic"`, `"oblique"` |
| `styleHint` | enum | Fallback hint for font matching |
| `underline` | bool | Underlined text |
| `strikeOut` | bool | Strikethrough text |
| `styleStrategy` | list | Rendering strategy hints |

## Weight Values

String values: `"thin"`, `"extraLight"`, `"light"`, `"normal"`, `"medium"`, `"demiBold"`, `"bold"`, `"extraBold"`, `"black"`

Or numeric: 1-1000 (400 = normal, 700 = bold)

## Style Hints

```nix
styleHint = "monospace";  # anyStyle, serif, sans, monospace, cursive, fantasy
```

## Style Strategy

List of rendering preferences:

```nix
styleStrategy = [ "preferAntialias" "preferQuality" ];
```

Options: `"prefer"`, `"matchingPrefer"`, `"antialiasing"`, `"noSubpixelAntialias"`, `"preferAntialias"`, `"openGLCompatible"`, `"forceIntegerMetrics"`, `"noFontMerging"`, `"preferNoShaping"`, `"preferMatch"`, `"preferQuality"`

## Example: Complete font config

```nix
fonts = {
  general = {
    family = "Inter";
    pointSize = 10;
    weight = "normal";
  };
  monospace = {
    family = "Izosevka";
    pointSize = 11;
    styleHint = "monospace";
  };
  small = {
    family = "Inter";
    pointSize = 8;
  };
  toolbar = {
    family = "Inter";
    pointSize = 10;
  };
  menu = {
    family = "Inter";
    pointSize = 10;
  };
  windowTitle = {
    family = "Inter";
    pointSize = 10;
    weight = "bold";
  };
};
```

## Config File Written

All font settings are written to `kdeglobals` under the `[General]` group using Qt font serialization format.
