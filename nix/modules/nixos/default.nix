{ flake, ... }:
{
  imports = [
    flake.nixosModules.nix
  ];

  nix.channel.enable = false;
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
}
