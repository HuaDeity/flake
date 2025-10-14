{
  flake,
  inputs,
  ...
}:
let
  user = "wangyizun";
in
{
  imports = [
    flake.homeModules.standalone
    inputs.pkgflow.homeModules.default
  ];

  config = {
    home.homeDirectory = "/nas/${user}";

    # Enable pkgflow manifest packages
    pkgflow.manifestPackages = {
      enable = true;
      manifestFile = flake + "/default/.flox/env/manifest.toml";
      flakeInputs = inputs;
    };
  };
}
