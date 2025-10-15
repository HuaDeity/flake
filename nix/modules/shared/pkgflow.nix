# Shared pkgflow configuration for all platforms
# Sets global defaults that can be used anywhere (system or home-manager)
{
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.pkgflow.sharedModules.default
  ];

  config = {
    pkgflow.manifest.file = "${inputs.self}/${config.self.floxDir}/env/manifest.toml";
  };
}
