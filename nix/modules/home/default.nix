{ perSystem, ... }:
{
  config = {
    home.stateVersion = "25.05";

    home.packages = [
      perSystem.flox.default
    ];

    nix.extraOptions = ''
      !include access-tokens.conf
    '';
  };
}
