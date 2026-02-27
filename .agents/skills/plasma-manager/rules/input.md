# Input: Keyboard, Mouse, Touchpad

All options under `programs.plasma.input`.

## Keyboard Layouts

```nix
input.keyboard = {
  layouts = [
    { layout = "us"; }
    { layout = "ru"; }
    { layout = "de"; variant = "nodeadkeys"; displayName = "DE"; }
  ];
  switchMode = "global";       # global, desktop, winClass, window
  numlock = "on";               # on, off, unchanged (default: unchanged)
};
```

**Layout fields:**
- `layout`: ISO 639 language code (us, ru, de, fr, etc.)
- `variant`: Layout variant (optional, e.g., "dvorak", "nodeadkeys")
- `displayName`: Custom label shown in layout switcher (optional)

**Switch modes:**
- `global`: Same layout everywhere
- `desktop`: Per virtual desktop
- `winClass`: Per window class
- `window`: Per individual window

## Mouse

```nix
input.mice = [
  {
    # Device identification (at least name or vendorId+productId)
    name = "Logitech G Pro";
    # vendorId = "046d";
    # productId = "c539";

    enable = true;
    leftHanded = false;
    middleButtonEmulation = false;
    pointerSpeed = 0.0;                # -1.0 to 1.0
    accelerationProfile = "none";       # none (flat), default (adaptive)
    naturalScroll = false;
  }
];
```

**Acceleration profiles:**
- `none`: Flat / no acceleration (1:1 mouse movement) -- preferred for gaming
- `default`: Adaptive acceleration

## Touchpad

```nix
input.touchpads = [
  {
    name = "ELAN Touchpad";
    # vendorId = "04f3";
    # productId = "3124";

    enable = true;
    disableWhileTyping = true;
    leftHanded = false;
    middleButtonEmulation = false;
    pointerSpeed = 0.0;                # -1.0 to 1.0
    accelerationProfile = "default";    # none, default
    naturalScroll = true;               # macOS-style scrolling
    tapToClick = true;
    tapAndDrag = true;
    tapAndDragLock = false;
    twoFingerTap = "rightClick";        # rightClick, middleClick, none
    rightClick = "twoFingers";          # twoFingers, pressInBottomRight, pressInBottomLeft
    scrollMethod = "twoFingers";        # twoFingers, edgeScroll, none
  }
];
```

## Config Files Written

- `kcminputrc` - Mouse and touchpad settings
- `kxkbrc` - Keyboard layouts and options

## Device Matching

Devices are matched by `name`, `vendorId`, and `productId`. You can find your device names with:

```bash
# List input devices
libinput list-devices
# Or check KDE settings
kcminputrc  # in ~/.config/
```

At minimum, provide `name` for matching. For precise matching (multiple similar devices), use `vendorId` + `productId`.
