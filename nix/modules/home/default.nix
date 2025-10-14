{
  flake,
  inputs,
  perSystem,
  ...
}:
{
  imports = [
    flake.nixosModules.pkgflow
    inputs.pkgflow.homeModules.default
  ];

  config = {
    home.stateVersion = "25.05";

    home.packages = [
      perSystem.flox.default
    ];

    nix.extraOptions = ''
      !include access-tokens.conf
    '';

    pkgflow.manifestPackages.flakeInputs = inputs;
  };
}
