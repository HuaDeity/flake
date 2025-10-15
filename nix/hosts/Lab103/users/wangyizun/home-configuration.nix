{
  inputs,
  ...
}:
let
  user = "wangyizun";
in
{
  imports = [
    inputs.self.homeModules.standalone
  ];

  config = {
    home.homeDirectory = "/nas/${user}";
  };
}
