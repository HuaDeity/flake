{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = with pkgs; [
      cri-tools
      kubernetes
    ];

    environment.etc."systemd/system/kubelet.service.d/10-kubeadm.conf".text = ''
      # Note: This dropin only works with kubeadm and kubelet v1.11+
      [Service]
      Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
      Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
      # This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
      EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
      # This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
      # the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
      EnvironmentFile=-/etc/sysconfig/kubelet
      ExecStart=
      ExecStart=${pkgs.kubernetes}/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
    '';

    environment.etc."kubernetes/manifests/kube-vip.yaml" = {
      source = ./config/kube-vip.yaml;
      mode = "0600";
    };

    systemd.services.kubelet = {
      enable = true;

      unitConfig = {
        Description = "kubelet: The Kubernetes Node Agent";
        Documentation = [ "https://kubernetes.io/docs/" ];
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      serviceConfig = {
        ExecStart = "${pkgs.kubernetes}/bin/kubelet";
        Restart = "always";
        StartLimitInterval = 0;
        RestartSec = 10;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
