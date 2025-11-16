{ inputs, ... }:
{
  imports = [
    inputs.self.modules.cluster.default
  ];
  config = {
    services.kubernetes = {
      roles = [
        "master"
        "node"
      ];
      kubeadm = {
        advertiseAddress = "192.168.103.57";
      };
      kube-vip = {
        interface = "eno2np1";
      };
    };

    # services.harmonia = {
    #   enable = true;
    #   signKeyPaths = [ "/var/lib/harmonia/cache-priv-key.pem" ];
    # };
  };
}
