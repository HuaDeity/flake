{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
  ];

  config = {
    nix.package = pkgs.nix;
    nix.gc.automatic = true;
  };
}
