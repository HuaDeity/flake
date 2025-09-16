{
  flake,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    (flake.lib.mkNixPackages {
      inherit lib pkgs;
      manifestFile = flake + "/default/.flox/env/manifest.toml";
      darwinMode = true;
    })
  ];
}
