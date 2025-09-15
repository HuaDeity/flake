{
  flake,
  lib,
  pkgs,
  ...
}: let
  user = "wangyizun";
in {
  imports = [
    flake.nixosModules.nix
    flake.homeModules.default
    (flake.lib.mkNixPackages {
      inherit lib pkgs;
      manifestFile = flake + "/flox/env/manifest.toml";
    })
  ];

  home.homeDirectory = "/nas/${user}";
}
