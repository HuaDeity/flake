{
  inputs,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.nix
    inputs.self.modules.container.containerd
    inputs.self.modules.container.kubernetes
    inputs.self.nixosModules.harmonia
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      perSystem.system-manager.default
      fish
      perSystem.flox.default
    ];

    container.kubernetes = {
      "kube-vip".enable = true;
      kubeadm.init = false;
    };

    services.harmonia = {
      enable = true;
      signKeyPaths = [ "/var/lib/harmonia/cache-priv-key.pem" ];
    };
  };
}
