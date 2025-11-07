{
  inputs,
  config,
  ...
}:
let
  floxAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.floxDir}/default-darwin/.flox";
in
{
  imports = [
    inputs.self.homeModules.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink floxAbsPath;
}
