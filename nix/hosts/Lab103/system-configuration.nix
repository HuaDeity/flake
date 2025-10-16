{
  inputs,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.nix
    # inputs.self.modules.container.containerd
    # inputs.self.modules.container.kubernetes
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];
    nix.settings.substituters = [ "http://192.168.103.57:5000" ];
    nix.settings.trusted-public-keys = [
      "harmonia-cache:l0LYxhBdXd9HN49z32harQ0VuxichxPcKbs6u5gna3o="
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      perSystem.system-manager.default
      fish
      perSystem.flox.default
    ];

    # container.kubernetes = {
    #   "kube-vip".enable = true;
    #   kubeadm.init = false;
    # };
  };
}
