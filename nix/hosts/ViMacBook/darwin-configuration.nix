{
  config,
  flake,
  lib,
  ...
}:
let
  user = "huadeity";
  brewPrefix = config.homebrew.brewPrefix;
in
{
  imports = [
    flake.darwinModules.default
    (flake.lib.mkDarwinUser user)
    (flake.lib.mkBrewPackages {
      inherit lib;
      manifestFile = flake + "/default/.flox/env/manifest.toml";
      mappingFile = flake + "/default/mapping.toml";
    })
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${user}.shell = "${brewPrefix}/fish";

  environment.profiles = lib.mkOrder 799 [ "$HOME/.local/state/nix/profile" ];

  homebrew = {
    enable = true;
    taps = [
      "domt4/autoupdate"
      "hakonharnes/tap"
      "homebrew/command-not-found"
      "huadeity/private"
      "laishulu/homebrew"
      "nrlquaker/createzap"
    ];
    brews = [
      "hugo"
      "laishulu/homebrew/macism"
      "mas"
      "hakonharnes/tap/pbctl"
      "pinentry-mac"
      "tag"
    ];
    casks = [
      "aldente"
      "apparency"
      "archaeology"
      "bettertouchtool"
      "bookends"
      "chatgpt"
      "cleanshot"
      "downie"
      "festivitas"
      "font-monaspace-var"
      "font-symbols-only-nerd-font"
      "ghostty"
      "gpg-suite@nightly"
      "ia-markdown-dictionary"
      "ia-presenter"
      "istat-menus"
      "kaleidoscope"
      "keka"
      "kekaexternalhelper"
      "libreoffice"
      "macupdater"
      "marked-app"
      "orbstack"
      "orion"
      "pearcleaner"
      "permute"
      "popclip"
      "qlmarkdown"
      "qlvideo"
      "qq"
      "rar"
      "raycast"
      "secretive"
      "sf-symbols"
      "shortcutie"
      "skim"
      "smash-smash"
      "steermouse"
      "supercharge"
      "surge"
      "suspicious-package"
      "syntax-highlight"
      "tencent-meeting"
      "thebrowsercompany-dia"
      "tower"
      "xscope"
      "zed@preview"
    ];
    masApps = {
      "Actions" = 1586435171;
      "Bear" = 1091189122;
      "Bob" = 1630034110;
      "Cardhop" = 1290358394;
      "Compressor" = 424390742;
      "Craft" = 1487937127;
      "Developer" = 640199958;
      "Dice by PCalc" = 1479250666;
      "Fantastical" = 975937182;
      "FilmNoir" = 1528417240;
      "Final Cut Pro" = 424389933;
      "Flighty" = 1358823008;
      "Folder Preview" = 6698876601;
      "GarageBand" = 682658836;
      "GoodLinks" = 1474335294;
      "GoodNotes" = 1444383602;
      "HextEdit" = 1557247094;
      "Highlights" = 1498912833;
      "iA Writer" = 775737590;
      "iMovie" = 408981434;
      "Infuse" = 1136220934;
      "Ivory" = 6444602274;
      "Just Press Record" = 1033342465;
      "Kagi for Safari" = 1622835804;
      "Keynote" = 409183694;
      "Logic Pro" = 634148309;
      "LookUp" = 872564448;
      "MainStage" = 634159523;
      "Maipo" = 789066512;
      "Mercury" = 1621800675;
      "MindNode Next" = 6446116532;
      "Motion" = 434290957;
      "MusicBox" = 1614730313;
      "MusicHarbor" = 1440405750;
      "MusicSmart" = 1512195368;
      "Night Sky" = 475772902;
      "Noir" = 1592917505;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Perplexity" = 6714467650;
      "Photomator" = 1444636541;
      "Pinning" = 6472634746;
      "Pixelmator Pro" = 1289583905;
      "Pizza Helper" = 1635319193;
      "Play" = 1596506190;
      "Prompt" = 1594420480;
      "Pure Paste" = 1611378436;
      "Reeder" = 6475002485;
      "Screens 5" = 1663047912;
      "Shareful" = 1522267256;
      "Shazem" = 897118787;
      "Sketch" = 1667260533;
      "SnippetsLab" = 1006087419;
      "StopTheMadness Pro" = 6471380298;
      "Streaks" = 963034692;
      "SubManager" = 1632853914;
      "Tampermonkey" = 6738342400;
      "Telegram" = 747648890;
      "TestFlight" = 899247664;
      "Tot" = 1491071483;
      "Tripsy" = 1429967544;
      "Turn Off the Lights for Safari" = 1273998507;
      "Velja" = 1607635845;
      "WaterMinder" = 1415257369;
      "Wayback Machine" = 1472432422;
      "Wipr" = 1662217862;
      "爱奇艺" = 1012296988;
      "腾讯视频" = 1231336508;
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  system.defaults.dock.persistent-apps = [
    "/System/Applications/Phone.app"
    "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
    "/Applications/Dia.app"
    "/System/Applications/Messages.app"
    "/Applications/ChatGPT.app"
    "/System/Applications/Music.app"
    "/System/Applications/Mail.app"
    "/Applications/Bookends.app"
    "/Applications/Tower.app"
    "/Applications/Ghostty.app"
    "/Applications/Zed Preview.app"
    "/Applications/Xcode.app"
  ];
  system.defaults.dock.persistent-others = [
    "${config.users.users.${user}.home}/Downloads"
  ];
}
