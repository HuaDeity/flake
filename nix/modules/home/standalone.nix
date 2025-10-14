{
  flake,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.modules.shared.pkgflow
    inputs.pkgflow.homeModules.default
  ];

  config = {
    nix.package = pkgs.nix;
    nix.gc.automatic = true;
  };
}
