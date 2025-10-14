{ flake, ... }:
{
  imports = [
    flake.nixosModules.nix
  ];

  config = {
    nix.channel.enable = false;
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    environment.pathsToLink = [ "/share/fish" ];
  };

}
