{ inputs, pkgs, ... }:
{
  imports = [
    inputs.self.nixosModules.nix
    inputs.self.modules.shared.default
  ];

  config = {
    environment.pathsToLink = [ "/share/fish" ];

    environment.systemPackages = with pkgs; [
      perSystem.flox.default
    ];

    nix.channel.enable = false;

    nix.gc.automatic = true;
    nix.optimise.automatic = true;
  };
}
