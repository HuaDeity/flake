{
  flake,
  perSystem,
  ...
}:
{
  imports = [
    flake.nixosModules.nix
    flake.modules.container.containerd
    flake.modules.container.kubernetes
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = [
      perSystem.system-manager.default
    ];

    container.kubernetes = {
      "kube-vip".enable = true;
      kubeadm.init = false;
    };
  };
}
