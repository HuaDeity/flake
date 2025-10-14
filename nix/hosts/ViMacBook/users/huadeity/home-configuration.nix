{
  flake,
  inputs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    flake.modules.shared.pkgflow
    inputs.pkgflow.homeModules.default
  ];

  config = {
    # Enable pkgflow manifest packages
    pkgflow.manifestPackages = {
      enable = true;
      requireSystemMatch = true;
    };
  };
}
