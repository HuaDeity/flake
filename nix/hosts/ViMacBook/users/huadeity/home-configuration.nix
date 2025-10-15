{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
  ];

  config = {
    # Enable pkgflow manifest packages
    pkgflow.manifestPackages.requireSystemMatch = true;
  };
}
