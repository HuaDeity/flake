{
  flake,
  lib,
  pkgs,
  ...
}:
let
  user = "wangyizun";
in
{
  imports = [
    flake.homeModules.standalone
    (flake.lib.mkNixPackages {
      inherit lib pkgs;
      manifestFile = flake + "/default/.flox/env/manifest.toml";
    })
  ];

  home.homeDirectory = "/nas/${user}";
}
