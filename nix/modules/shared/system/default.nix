{
  perSystem,
  pkgs,
  ...
}:

{
  imports = [
    ../default.nix
    ./nix.nix
  ];

  config = {
    environment.pathsToLink = [ "/share/fish" ];

    environment.systemPackages = [
      perSystem.flox.default
      pkgs.nh
      pkgs.nixfmt
      pkgs.nixd
    ];
  };
}
