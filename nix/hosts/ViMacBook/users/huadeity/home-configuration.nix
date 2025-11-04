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
    pkgflow.substituters.enable = true;
  };
}
