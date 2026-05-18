{
  inputs,
  config,
  ...
}:
let
  # homeAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.homeModuleDir}";
in
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  # home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink (homeAbsPath + "/flox");

  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleIconAppearanceTheme = "RegularAutomatic";
      AppleICUForce24HourTime = true;
      AppleKeyboardUIMode = 2;
      AppleLanguages = [
        "en-US"
      ];
      AppleLocale = "en_US";
      ApplePressAndHoldEnabled = false;
      NSQuitAlwaysKeepsWindows = true;
      "com.apple.keyboard.fnState" = true;
    };
    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
    };
    "com.apple.dock" = {
      autohide = true;
      expose-group-apps = true;
      minimize-to-application = true;
      show-process-indicators = false;
    };
    "com.apple.HIToolbox" = {
      AppleFnUsageType = 1;
    };
    "com.apple.menuextra.clock" = {
      ShowDate = 2;
      ShowDayOfWeek = false;
    };
    "com.apple.Safari" = {
      IncludeDevelopMenu = true;
      ShowStandaloneTabBar = false;
    };
  };

  targets.darwin.currentHostDefaults = {
    NSGlobalDomain = {
      "com.apple.mouse.tapBehavior" = 1;
    };
    "com.apple.controlcenter" = {
      BatteryShowPercentage = true;
      Weather = 2; # Not working
    };
  };
}
