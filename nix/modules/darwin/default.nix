{ inputs, ... }:
{
  imports = [
    inputs.self.modules.shared.system
    inputs.pkgflow.brewModules.default # Homebrew module (for homebrew.brews/casks)
    ./primaryUser.nix
  ];

  config = {
    nix.settings.trusted-users = [ "@admin" ];

    programs.bash = {
      interactiveShellInit = ''
        PS1='\h:\W \u\$ '
      '';
    };

    programs.zsh = {
      enableBashCompletion = false;
      enableGlobalCompInit = false;
      interactiveShellInit = ''
        # Correctly display UTF-8 with combining characters.  We'll assume UTF-8 if the
        # locale(1) binary is missing entirely.
        if [[ ! -x /usr/bin/locale ]] || [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
            setopt COMBINING_CHARS
        fi

        # Disable the log builtin, so we don't conflict with /usr/bin/log
        disable log

        # Default prompt
        PS1="%n@%m %1~ %# "

        # Useful support for interacting with Terminal.app or other terminal programs
        [ -r "/etc/zshrc_$TERM_PROGRAM" ] && . "/etc/zshrc_$TERM_PROGRAM"
      '';
      loginShellInit = ''
        if [ -z "$LANG" ]; then
          export LANG=C.UTF-8
        fi

        if [ -x /usr/libexec/path_helper ]; then
          eval `/usr/libexec/path_helper -s`
        fi
      '';
      promptInit = "";
    };

    security = {
      pam = {
        services = {
          sudo_local = {
            reattach = true;
            touchIdAuth = true;
          };
        };
      };
    };

    system.defaults = {
      dock = {
        autohide = true;
        show-recents = true;
        launchanim = true;
        orientation = "bottom";
      };

      hitoolbox = {
        AppleFnUsageType = "Change Input Source";
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 2;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = false;

        KeyRepeat = 6; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 35; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 1.0;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    system.stateVersion = 6;
  };
}
