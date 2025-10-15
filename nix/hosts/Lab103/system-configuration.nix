{
  inputs,
  perSystem,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.nix
    inputs.self.modules.container.containerd
    inputs.self.modules.container.kubernetes
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
