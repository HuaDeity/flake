{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.default
  ];

  config = {
    # Enable pkgflow manifest packages
    pkgflow.requireSystemMatch = true;
    pkgflow.caches.enable = true;
  };
}
