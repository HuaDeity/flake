{
  flake,
  ...
}:
{
  imports = [
    flake.homeModules.default
  ];

  config = {
    # Enable pkgflow manifest packages
    pkgflow.manifestPackages = {
      enable = true;
      requireSystemMatch = true;
    };
  };
}
