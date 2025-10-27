{
  inputs,
  perSystem,
  pkgs,
  ...
}:
let
  virtualIp = "192.168.103.200";
in
{
  imports = [
    inputs.self.modules.shared.system
    inputs.self.modules.cluster.kubernetes
    inputs.self.modules.networking.harmonia
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      perSystem.system-manager.default
      fish
    ];

    services.kubernetes = {
      kubeadm = {
        controlPlaneEndpoint = "${virtualIp}:6443";
        kubernetesVersion = "1.34.1";
      };
      kube-vip = {
        address = virtualIp;
        loadBalance = true;
        kubeVipVersion = "v1.0.1";
      };
    };

    virtualisation.containerd = {
      nvidia = true;
      settings = {
        plugins."io.containerd.cri.v1.images" = {
          registry.config_path = "/etc/containerd/certs.d";
        };
      };
    };

    environment.etc = {
      "containerd/certs.d/registry.k8s.io/hosts.toml".text = ''
        [host."k8s.m.daocloud.io"]
          capabilities = ["pull", "resolve"]
      '';
      "containerd/certs.d/docker.io/hosts.toml".text = ''
        [host."docker.m.daocloud.io"]
          capabilities = ["pull", "resolve"]
      '';
    };
  };
}
