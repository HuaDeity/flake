{
  inputs,
  config,
  ...
}:
let
  homeAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.homeModuleDir}";
in
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  home.file.".flox/env/manifest.toml".source = config.lib.file.mkOutOfStoreSymlink (
    homeAbsPath + "/flox/env/nix.toml"
  );
  home.file.".flox/env.json".source = config.lib.file.mkOutOfStoreSymlink (
    homeAbsPath + "/flox/env.json"
  );
  home.file.".flox/.gitignore".source = config.lib.file.mkOutOfStoreSymlink (
    homeAbsPath + "/flox/.gitignore"
  );
  home.file.".flox/.gitattributes".source = config.lib.file.mkOutOfStoreSymlink (
    homeAbsPath + "/flox/.gitattributes"
  );
}
