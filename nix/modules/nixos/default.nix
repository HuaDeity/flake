{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.nix
    inputs.self.modules.shared.default
  ];

  config = {
    environment.pathsToLink = [ "/share/fish" ];

    nix.channel.enable = false;

    nix.gc.automatic = true;
    nix.optimise.automatic = true;
  };
}
