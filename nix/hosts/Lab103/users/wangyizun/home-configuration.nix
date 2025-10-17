{
  inputs,
  ...
}:
let
  user = "wangyizun";
in
{
  imports = [
    inputs.self.homeModules.default
  ];

  config = {
    home.homeDirectory = "/nas/${user}";
  };
}
