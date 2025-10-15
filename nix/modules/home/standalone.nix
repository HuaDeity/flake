{
  pkgs,
  ...
}:
{
  imports = [
    ./default.nix
  ];

  config = {
    nix.package = pkgs.nix;
    nix.gc.automatic = true;
  };
}
