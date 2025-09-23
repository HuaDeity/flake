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

  nix.extraOptions = ''
    # Nix configuration
    !include access-tokens.conf
  '';
}
