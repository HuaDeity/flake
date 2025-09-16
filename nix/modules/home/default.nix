{
  inputs,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";

  home.packages = [
    inputs.flox.packages.${pkgs.system}.default
  ];
}
