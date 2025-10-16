{
  config,
  ...
}:
let
  floxAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.floxDir}";
in
{
  config = {
    # Add .flox directory to home (writable, out-of-store symlink)
    home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink floxAbsPath;
  };
}
