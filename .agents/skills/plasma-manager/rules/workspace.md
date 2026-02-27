# Workspace: Themes, Colors, Wallpaper, Cursors

All options under `programs.plasma.workspace`.

## Look and Feel (Global Theme)

```nix
workspace = {
  lookAndFeel = "org.kde.breezedark.desktop";  # Global theme package
  theme = "breeze-dark";          # Plasma style (visual theme)
  colorScheme = "BreezeDark";     # Color scheme name
  widgetStyle = "breeze";         # Qt widget style
};
```

## Cursor

```nix
workspace.cursor = {
  theme = "Bibata-Modern-Ice";    # Cursor theme name
  size = 24;                       # Cursor size in pixels
};
```

## Icon Theme

```nix
workspace.iconTheme = "Papirus-Dark";
```

## Wallpaper

Four modes available (mutually exclusive):

### Static wallpaper
```nix
# Single image
workspace.wallpaper = "/path/to/image.png";

# From nixpkgs wallpaper package
workspace.wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
```

### Wallpaper slideshow
```nix
workspace.wallpaperSlideShow = {
  path = "/home/user/Pictures/Wallpapers";
  # Or multiple paths:
  # path = [ "/path1" "/path2" ];
  interval = 300;  # seconds between changes
};
```

### Picture of the Day
```nix
workspace.wallpaperPictureOfTheDay = {
  provider = "bing";  # Options: apod, bing, flickr, natgeo, noaa, wcpotd, epod, simonstalenhag
  updateOverMeteredConnection = false;
};
```

### Plain color
```nix
workspace.wallpaperPlainColor = "40,42,54";  # RGB string
```

### Fill mode (applies to static and slideshow)
```nix
workspace.wallpaperFillMode = "preserveAspectCrop";
# Options: stretch, preserveAspectFit, preserveAspectCrop, tile,
#          tileVertically, tileHorizontally, pad
```

## Window Decorations

```nix
workspace.windowDecorations = {
  library = "org.kde.breeze";     # Decoration engine
  theme = "Breeze";               # Decoration theme name
};
```

## Splash Screen

```nix
workspace.splashScreen = {
  engine = "none";    # "none" to disable
  theme = "None";
};
```

## Sound Theme

```nix
workspace.soundTheme = "ocean";
```

## Behavior

```nix
workspace = {
  clickItemTo = "open";            # "open" (single-click) or "select" (double-click)
  enableMiddleClickPaste = true;   # Middle-click paste from selection clipboard
  tooltipDelay = 700;              # Tooltip delay in milliseconds
};
```

## Config Files Affected

- `kdeglobals` - cursor, icon theme, widget style, color scheme
- `plasmarc` - plasma theme
- `kcminputrc` - cursor theme and size
- `klaunchrc` - launch feedback cursor
- `ksplashrc` - splash screen
- `kwinrc` - window decorations
