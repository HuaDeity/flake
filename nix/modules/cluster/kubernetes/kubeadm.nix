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

  initConfig = {
    apiVersion = "kubeadm.k8s.io/v1beta4";
    kind = "InitConfiguration";
  }
  // lib.optionalAttrs (cfg.advertiseAddress != null) {
    localAPIEndpoint = {
      advertiseAddress = cfg.advertiseAddress;
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

  kubeadmDocs = [
    initConfig
    clusterConfig
  ];

  format = pkgs.formats.yaml_1_2 { };

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
    environment.etc."kubeadm.yaml".source = (format.generate "kubeadm.yaml" kubeadmDocs);
  };
}
