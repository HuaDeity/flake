{flake, ...}: {
  imports = [
    flake.nixosModules.nix
  ];

  nix.channel.enable = false;
}
