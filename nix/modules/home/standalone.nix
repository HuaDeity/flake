{ flake, pkgs, ... }:
{
  imports = [
    flake.homeModules.default
  ];

  nix.package = pkgs.nix;
  nix.gc.automatic = true;
}
