{ inputs, ... }:
{
  imports = [
    inputs.self.modules.cluster.default
  ];
  config = {
    services.kubernetes = {
      roles = [
        "init"
        "node"
      ];
      kubeadm = {
        controlPlaneEndpoint = "192.168.103.200:6443";
        kubernetesVersion = "1.34.1";
        advertiseAddress = "192.168.103.57";
      };
      kube-vip = {
        address = "192.168.103.200";
        interface = "eno2";
        kubeVipVersion = "v1.0.1";
      };
    };
  };
}
