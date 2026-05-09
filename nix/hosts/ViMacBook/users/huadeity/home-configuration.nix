{
  inputs,
  # config,
  ...
}:
let
  # homeAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.homeModuleDir}";
in
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  # home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink (homeAbsPath + "/flox");
}
