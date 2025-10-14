{ flake, ... }:
{
  imports = [
    flake.nixosModules.nix
    flake.nixosModules.pkgflow
  ];

  config = {
    nix.channel.enable = false;
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    environment.pathsToLink = [ "/share/fish" ];
  };
}
