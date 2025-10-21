{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  top = config.services.kubernetes;
  otop = options.services.kubernetes;
  cfg = top.kubeadm;

  baseConfig = {
    apiVersion = "kubeadm.k8s.io/v1beta4";
    kind = if lib.elem "init" top.roles then "InitConfiguration" else "JoinConfiguration";
  }
  // lib.optionalAttrs (lib.elem "init" top.roles) {
    localAPIEndpoint = {
      advertiseAddress = cfg.advertiseAddress;
    };
  }
  // lib.optionalAttrs (lib.elem "master" top.roles) {
    controlPlane = {
      localAPIEndpoint = {
        advertiseAddress = cfg.advertiseAddress;
      };
      certificateKey = "13d7246e1cf19e4da30e02375a687a2a3a985d12df482854786066749f9736e5";
    };
  }
  // lib.optionalAttrs (!(lib.elem "init" top.roles)) {
    discovery = {
      bootstrapToken = {
        token = "dn7xsy.benqmr16ijc5a2x5";
        apiServerEndpoint = cfg.controlPlaneEndpoint;
        caCertHashes = [
          "sha256:b01f4eab023a9e380d96b7310897838aca4b9d00603ffb9ffe3ee2022452bcab"
        ];
      };
    };
  }
  // lib.optionalAttrs (cfg.taints != null) {
    nodeRegistration = {
      taints = cfg.taints;
    };
  };

  clusterConfig = {
    apiVersion = "kubeadm.k8s.io/v1beta4";
    kind = "ClusterConfiguration";
    kubernetesVersion = cfg.kubernetesVersion;
  }
  // lib.optionalAttrs (cfg.controlPlaneEndpoint != null) {
    controlPlaneEndpoint = cfg.controlPlaneEndpoint;
  };

  format = pkgs.formats.yaml_1_2 { };
  yamlDocSeparator = builtins.toFile "yaml-doc-separator" "\n---\n";

  configs = [
    baseConfig
  ]
  ++ lib.optional (lib.elem "init" top.roles) clusterConfig;
  # ++ lib.optional (cfg.kubeletConfig != null) cfg.kubeletConfig;

  # Generate YAML docs with separators between them
  yamlDocs = lib.concatLists (
    lib.imap0 (
      i: doc:
      if i == 0 then
        [ (format.generate "config-${toString i}.yaml" doc) ]
      else
        [
          yamlDocSeparator
          (format.generate "config-${toString i}.yaml" doc)
        ]
    ) configs
  );

  taintOptions = with lib.types; {
    options = {
      key = mkOption {
        description = "Key of taint.";
        type = str;
      };
      value = mkOption {
        description = "Value of taint.";
        type = str;
      };
      effect = mkOption {
        description = "Effect of taint.";
        example = "NoSchedule";
        type = enum [
          "NoSchedule"
          "PreferNoSchedule"
          "NoExecute"
        ];
      };
    };
  };
in
{
  options.services.kubernetes.kubeadm = with types; {
    advertiseAddress = lib.mkOption {
      description = ''
        Kubernetes apiserver IP address on which to advertise the apiserver
        to members of the cluster. This address must be reachable by the rest
        of the cluster.
      '';
      default = null;
      type = nullOr str;
    };

    controlPlaneEndpoint = mkOption {
      description = "Load-balanced endpoint that kubeadm advertises to cluster members.";
      default = null;
      type = nullOr str;
    };

    enable = mkEnableOption "kubeadm";

    kubernetesVersion = mkOption {
      description = "Kubernetes version string exported in the ClusterConfiguration document.";
      default = pkgs.kubernetes.version;
      defaultText = lib.literalMD "pkgs.kubernetes.version";
      type = str;
    };

    taints = mkOption {
      description = "Node taints (https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).";
      default = null;
      type = types.nullOr (listOf (submodule [ taintOptions ]));
    };
  };

  config = mkIf cfg.enable {
    environment.etc."kubeadm.yaml".source = pkgs.concatText "kubeadm.yaml" yamlDocs;
    systemd.services.kubelet = {
      overrideStrategy = "asDropin";
      environment = {
        KUBELET_KUBECONFIG_ARGS = "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf";
        KUBELET_CONFIG_ARGS = "--config=/var/lib/kubelet/config.yaml";
      };
      serviceConfig = {
        EnvironmentFile = [
          "-/var/lib/kubelet/kubeadm-flags.env"
          "-/etc/sysconfig/kubelet"
        ];

        ExecStart = [
          "" # Clear the existing ExecStart
          "${top.package}/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS"
        ];
      };

    };
  };
}
