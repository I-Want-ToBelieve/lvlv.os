{
  flake.modules.darwin.macos-defaults = {
    config,
    lib,
    ...
  }: {
    networking.computerName = lib.mkDefault config.networking.hostName;

    system.defaults = {
      smb.NetBIOSName = lib.mkDefault config.networking.hostName;
      menuExtraClock.Show24Hour = true;

      dock = {
        autohide = false;
        show-recents = false;
        # Hot corners: 1 means no action.
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        # Search the current folder.
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
        "com.apple.sound.beep.feedback" = 0;
        # F1–F12 act as function keys.
        "com.apple.keyboard.fnState" = true;
        AppleInterfaceStyle = "Dark";
        # Full keyboard access to every control.
        AppleKeyboardUIMode = 3;
        # Holding a key repeats it (hjkl in vim) instead of offering accented letters.
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Automatic";
        AppleSpacesSwitchOnActivate = true;
        # In units of 15 ms: a 225 ms delay, then a repeat every 45 ms.
        InitialKeyRepeat = 15;
        KeyRepeat = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      screencapture = {
        location = "~/Desktop";
        type = "png";
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };

      # Preferences that nix-darwin has no typed option for.
      CustomUserPreferences = {
        NSGlobalDomain.WebKitDeveloperExtras = true;
        # No .DS_Store files on network and USB volumes.
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        # Do not open Photos when a device is plugged in.
        "com.apple.ImageCapture".disableHotPlug = true;
      };
    };
  };
}
