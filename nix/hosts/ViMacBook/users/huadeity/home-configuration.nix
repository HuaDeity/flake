{
  flake,
  inputs,
  ...
}:
{
  imports = [
    flake.homeModules.default
    inputs.pkgflow.homeModules.default
  ];

  config = {
    pkgflow.manifestPackages = {
      enable = true;
      manifestFile = flake + "/default/.flox/env/manifest.toml";
      flakeInputs = inputs;
      requireSystemMatch = true;
    };
  };
}
