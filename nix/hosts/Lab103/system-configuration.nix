{
  flake,
  perSystem,
  pkgs,
  ...
}:
let
  pathDir = "/run/system-manager/sw";
in
{
  imports = [
    flake.modules.linux.default
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment = {
      systemPackages = with pkgs; [
        cni-plugins
        cri-tools
        containerd
        kubernetes
        nerdctl
        runc
        perSystem.system-manager.default
      ];
      etc."systemd/system/kubelet.service.d/10-kubeadm.conf".text = ''
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
        ExecStart=${pathDir}/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
      '';
    };

    systemd.services = {
      kubelet = {
        enable = true;

        unitConfig = {
          Description = "kubelet: The Kubernetes Node Agent";
          Documentation = [ "https://kubernetes.io/docs/" ];
          Wants = [ "network-online.target" ];
          After = [ "network-online.target" ];
        };

        serviceConfig = {
          ExecStart = "${pathDir}/bin/kubelet";
          Restart = "always";
          StartLimitInterval = 0;
          RestartSec = 10;
        };

        wantedBy = [ "multi-user.target" ];
      };

      containerd = {
        enable = true;

        unitConfig = {
          Description = "containerd container runtime";
          Documentation = [ "https://containerd.io" ];
          After = [
            "network.target"
            "dbus.service"
          ];
        };

        serviceConfig = {
          ExecStartPre = "-/sbin/modprobe overlay";
          ExecStart = "${pathDir}/bin/containerd";

          Type = "notify";
          Delegate = "yes";
          KillMode = "process";
          Restart = "always";
          RestartSec = 5;

          LimitNPROC = "infinity";
          LimitCORE = "infinity";

          TasksMax = "infinity";
          OOMScoreAdjust = -999;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
