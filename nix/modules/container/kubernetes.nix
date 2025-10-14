{ config, lib, pkgs, ... }:

let
  cfg = config.container.kubernetes;
  kubeVipCfg = cfg."kube-vip";

  kubeVipBase = builtins.readFile ./config/kube-vip.yaml;
  kubeVipText =
    if cfg.kubeadm.init then
      lib.replaceStrings
        [ "path: /etc/kubernetes/admin.conf" ]
        [ "path: /etc/kubernetes/super-admin.conf" ]
        kubeVipBase
    else
      kubeVipBase;
in
{
  options.container.kubernetes = {
    "kube-vip" = {
      enable =
        (lib.mkEnableOption "the kube-vip static pod manifest")
        // { default = true; };
    };

    kubeadm.init = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use the super-admin kubeconfig when preparing for kubeadm init.";
    };
  };

  config =
    {
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
    }
    // lib.mkIf kubeVipCfg.enable {
      environment.etc."kubernetes/manifests/kube-vip.yaml" = {
        text = kubeVipText;
        mode = "0600";
      };
    };
}
