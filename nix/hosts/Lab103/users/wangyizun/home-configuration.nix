{
  inputs,
  config,
  ...
}:
let
  user = "wangyizun";
  floxAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.floxDir}/default/.flox";
in
{
  imports = [
    inputs.self.homeModules.default
  ];

  config = {
    home.homeDirectory = "/nas/${user}";
    home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink floxAbsPath;
  };
}
