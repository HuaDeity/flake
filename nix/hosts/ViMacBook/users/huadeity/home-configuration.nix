{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.nixModules.default
  ];

  config = {
    # Enable pkgflow manifest packages
    pkgflow.manifestPackages.requireSystemMatch = true;
  };
}
