{ pkgs, ... }:
{
  config = import ../nixos/nix.nix { inherit pkgs; };
}
