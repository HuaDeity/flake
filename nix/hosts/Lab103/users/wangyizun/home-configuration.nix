{
  flake,
  ...
}:
let
  user = "wangyizun";
in
{
  imports = [
    flake.homeModules.standalone
  ];

  config = {
    home.homeDirectory = "/nas/${user}";

    # Enable pkgflow manifest packages
    pkgflow.manifestPackages.enable = true;
  };
}
