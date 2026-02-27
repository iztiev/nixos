# Power Management and Session

## PowerDevil (`powerdevil`)

Three power profiles: `AC`, `battery`, `lowBattery`. Each supports the same options.

```nix
powerdevil = {
  AC = {
    powerButtonAction = "lockScreen";
    # Options: nothing, sleep, hibernate, shutDown, lockScreen, turnOffScreen

    autoSuspend = {
      action = "sleep";           # nothing, sleep, hibernate, shutDown
      idleTimeout = 600;          # seconds before auto-suspend (null to disable)
    };

    whenLaptopLidClosed = "sleep";
    # Options: nothing, sleep, hibernate, shutDown, lockScreen, turnOffScreen

    whenSleepingEnter = "standby";
    # Options: standby, standbyThenHibernate, hybridSleep

    turnOffDisplay = {
      idleTimeout = 300;           # seconds, or "never"
      idleTimeoutWhenLocked = 60;  # seconds, or "immediately", or "never"
    };

    dimDisplay = {
      enable = true;
      idleTimeout = 120;           # seconds before dimming
    };

    inhibitLidActionWhenExternalMonitorConnected = false;
  };

  battery = {
    powerButtonAction = "sleep";
    autoSuspend = {
      action = "sleep";
      idleTimeout = 300;
    };
    whenLaptopLidClosed = "sleep";
    whenSleepingEnter = "standbyThenHibernate";
    turnOffDisplay = {
      idleTimeout = 120;
      idleTimeoutWhenLocked = "immediately";
    };
  };

  lowBattery = {
    powerButtonAction = "hibernate";
    whenLaptopLidClosed = "hibernate";
    autoSuspend = {
      action = "hibernate";
      idleTimeout = 120;
    };
    turnOffDisplay = {
      idleTimeout = 60;
      idleTimeoutWhenLocked = "immediately";
    };
  };
};
```

## Screen Locker (`kscreenlocker`)

```nix
kscreenlocker = {
  autoLock = true;                # Auto-lock after timeout
  lockOnResume = true;            # Lock on wake from suspend
  lockOnStartup = false;          # Lock at session start
  timeout = 10;                   # Minutes before auto-lock
  passwordRequired = true;
  passwordRequiredDelay = 5;      # Seconds grace period after lock

  appearance = {
    alwaysShowClock = true;
    showMediaControls = true;

    # Lockscreen wallpaper (same options as workspace wallpaper)
    wallpaper = "/path/to/image.png";
    # Or:
    wallpaperPictureOfTheDay = { provider = "bing"; };
    # Or:
    wallpaperSlideShow = { path = "/path/to/folder"; interval = 300; };
    # Or:
    wallpaperPlainColor = "0,0,0";
  };
};
```

## Session (`session`)

```nix
session = {
  general.askForConfirmationOnLogout = true;

  sessionRestore = {
    restoreOpenApplicationsOnLogin = "startWithEmptySession";
    # Options: onLastLogout, whenSessionWasManuallySaved, startWithEmptySession
    excludeApplications = [ "org.kde.konsole" ];  # Apps to not restore
  };
};
```

## Config Files Written

- `powerdevilrc` - Power management settings
- `kscreenlockerrc` - Screen locker settings
- `ksmserverrc` - Session manager settings
