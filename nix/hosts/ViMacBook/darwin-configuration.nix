{
  inputs,
  config,
  lib,
  ...
}:
let
  user = "huadeity";
  brewPrefix = config.homebrew.brewPrefix;
in
{
  imports = [
    inputs.self.darwinModules.default
  ];

  config = {
    nixpkgs.hostPlatform = "aarch64-darwin";

    darwin.primaryUser.name = user;

    users.users.${user}.shell = "${brewPrefix}/fish";

    environment.profiles = lib.mkOrder 799 [ "$HOME/.local/state/nix/profile" ];

    homebrew = {
      enable = true;
      taps = [
        "domt4/autoupdate"
        "hakonharnes/tap"
        "huadeity/private"
        "huadeity/tap"
        "laishulu/homebrew"
        "nrlquaker/createzap"
      ];
      brews = [
        "container"
        "container-compose"
        "fish"
        "hugo"
        "macism"
        "mas"
        "pbctl"
        "pinentry-mac"
        "tag"
        "tex-fmt"
        "texlab"
      ];
      casks = [
        "aldente"
        "antinote"
        "apparency"
        "archaeology"
        "basictex"
        "bettertouchtool"
        "claude"
        "cleanshot"
        "crossover"
        "downie"
        "drawio"
        "folder-preview-pro"
        "font-commit-mono-nerd-font"
        "ghostty"
        "hazeover"
        "helium-browser"
        "istat-menus"
        "kaleidoscope"
        "keka"
        "kekaexternalhelper"
        "onyx"
        "pearcleaner"
        "permute"
        "popclip"
        "qlvideo"
        "rar"
        "raycast"
        "secretive"
        "sf-symbols"
        "shortcutie"
        "skim"
        "sleeve"
        "spotify"
        "supercharge"
        "surge"
        "suspicious-package"
        "syntax-highlight"
        "tower"
        "vesktop"
        "zed@preview"
        "zotero"
      ];
      masApps = {
        "Actions" = 1586435171;
        "Anybox" = 1593408455;
        "Bear" = 1091189122;
        "Bob" = 1630034110;
        "Cardhop" = 1290358394;
        "Compressor" = 6746516157;
        "Craft" = 1487937127;
        "Developer" = 640199958;
        "Dice by PCalc" = 1479250666;
        "Fantastical" = 975937182;
        "Final Cut Pro" = 1631624924;
        "Flighty" = 1358823008;
        "GoodLinks" = 1474335294;
        "Infuse" = 1136220934;
        "Keynote" = 361285480;
        "Kindle" = 302584613;
        "Logic Pro" = 1615087040;
        "LookUp" = 872564448;
        "MainStage" = 6746637089;
        "Maipo" = 789066512;
        "Markdown Preview" = 6739955340;
        # "Marked 3" = 0;
        "Microsoft Excel" = 462058435;
        "Microsoft PowerPoint" = 462062816;
        "Microsoft Word" = 462054704;
        "Mona" = 6755672518;
        "Motion" = 6746637149;
        "MusicBox" = 1614730313;
        "MusicHarbor" = 1440405750;
        "MusicSmart" = 1512195368;
        "Night Sky" = 475772902;
        "Noir" = 1592917505;
        "Numbers" = 361304891;
        "OneDrive" = 823766827;
        "Pages" = 361309726;
        "Photomator" = 1444636541;
        "Pinning" = 6472634746;
        "Pixelmator Pro" = 6746662575;
        "Play" = 1596506190;
        "Prompt" = 1594420480;
        "Pure Paste" = 1611378436;
        "QQ" = 451108668;
        "Reeder" = 6475002485;
        "Shareful" = 1522267256;
        "Sketch" = 1667260533;
        "Slack" = 803453959;
        "StopTheMadness Pro" = 6471380298;
        "Streaks" = 963034692;
        "SubManager" = 1632853914;
        "Telegram" = 747648890;
        "TencentMeeting" = 1484048379;
        "TestFlight" = 899247664;
        "Tot" = 1491071483;
        "Tripsy" = 1429967544;
        "Velja" = 1607635845;
        "WaterMinder" = 1415257369;
        "WeChat" = 836500024;
        "Wipr" = 1662217862;
        "Xcode" = 497799835;
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
      "/Applications/Helium.app"
      "/System/Applications/Messages.app"
      "/System/Applications/Music.app"
      "/System/Applications/Mail.app"
      "/Applications/Reeder.app"
      "/Applications/Bear.app"
      "/Applications/Ghostty.app"
      "/Applications/Xcode.app"
    ];
    system.defaults.dock.persistent-others = [
      "${config.users.users.${user}.home}/Downloads"
    ];
  };
}
