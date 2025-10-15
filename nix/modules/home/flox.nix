{
  config,
  perSystem,
  ...
}:
let
  floxAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.floxDir}";
in
{
  config = {
    home.packages = [
      perSystem.flox.default
    ];

    # Add .flox directory to home (writable, out-of-store symlink)
    home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink floxAbsPath;
  };
}
