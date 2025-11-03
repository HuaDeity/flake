{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  config = {
    pkgflow.caches.enable = true;
  };
}
