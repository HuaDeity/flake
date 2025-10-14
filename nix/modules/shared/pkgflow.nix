# Shared pkgflow configuration for all platforms
# Sets global defaults that can be used anywhere (system or home-manager)
{ flake, inputs, ... }:

{
  imports = [
    # Import the shared module that defines pkgflow.manifest option
    inputs.pkgflow.nixosModules.shared
  ];

  config = {
    # Set global manifest file path (used by all pkgflow modules)
    pkgflow.manifest.file = flake + "/default/.flox/env/manifest.toml";

    # Set flakeInputs for resolving flake-based packages
    pkgflow.manifestPackages.flakeInputs = inputs;
  };
}
