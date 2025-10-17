{
  config,
  inputs,
  ...
}:
let
  floxAbsPath = "${config.home.homeDirectory}/${config.self.flakeDir}/${config.self.floxDir}";
in
{
  imports = [
    inputs.self.modules.shared.default
  ];

  config = {
    home.stateVersion = "25.05";

    nix.extraOptions = ''
      !include access-tokens.conf
    '';

    home.file.".flox".source = config.lib.file.mkOutOfStoreSymlink floxAbsPath;
  };
}
