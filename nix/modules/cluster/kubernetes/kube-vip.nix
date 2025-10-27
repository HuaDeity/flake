{
  config,
  lib,
  options,
  ...
}:

with lib;

let
  top = config.services.kubernetes;
  otop = options.services.kubernetes;
  cfg = top.kube-vip;

  baseEnv = [
    {
      name = "vip_arp";
      value = "true";
    }
    {
      name = "port";
      value = "6443";
    }
    {
      name = "vip_nodename";
      valueFrom.fieldRef.fieldPath = "spec.nodeName";
    }
    {
      name = "vip_interface";
      value = cfg.interface;
    }
    {
      name = "vip_subnet";
      value = "32";
    }
    {
      name = "dns_mode";
      value = "first";
    }
    {
      name = "cp_enable";
      value = "true";
    }
    {
      name = "cp_namespace";
      value = "kube-system";
    }
    {
      name = "svc_enable";
      value = "true";
    }
    {
      name = "svc_leasename";
      value = "plndr-svcs-lock";
    }
    {
      name = "vip_leaderelection";
      value = "true";
    }
    {
      name = "vip_leasename";
      value = "plndr-cp-lock";
    }
    {
      name = "vip_leaseduration";
      value = "5";
    }
    {
      name = "vip_renewdeadline";
      value = "3";
    }
    {
      name = "vip_retryperiod";
      value = "1";
    }
    {
      name = "address";
      value = cfg.address;
    }
    {
      name = "prometheus_server";
      value = ":2112";
    }
  ];

  manifest = {
    apiVersion = "v1";
    kind = "Pod";
    metadata = {
      name = "kube-vip";
      namespace = "kube-system";
    };
    spec = {
      containers = [
        {
          args = [ "manager" ];
          env = baseEnv ++ cfg.extraEnv;
          image = "ghcr.io/kube-vip/kube-vip:${cfg.kubeVipVersion}";
          imagePullPolicy = "IfNotPresent";
          name = "kube-vip";
          resources = { };
          securityContext.capabilities = {
            add = [
              "NET_ADMIN"
              "NET_RAW"
            ];
            drop = [ "ALL" ];
          };
          volumeMounts = [
            {
              mountPath = "/etc/kubernetes/admin.conf";
              name = "kubeconfig";
            }
          ];
        }
      ];
      hostAliases = [
        {
          hostnames = [ "kubernetes" ];
          ip = "127.0.0.1";
        }
      ];
      hostNetwork = true;
      volumes = [
        {
          hostPath.path =
            if lib.elem "init" top.roles then
              "/etc/kubernetes/super-admin.conf"
            else
              "/etc/kubernetes/admin.conf";
          name = "kubeconfig";
        }
      ];
    };
    status = { };
  };
in

{
  options.services.kubernetes.kube-vip = with types; {
    address = mkOption {
      description = "Virtual IP address advertised by kube-vip.";
      type = str;
    };

    enable = mkEnableOption "Kubernetes kube-vip";

    interface = mkOption {
      description = "Network interface kube-vip binds to.";
      type = str;
    };

    extraEnv = mkOption {
      description = "Additional environment variables for the kube-vip container.";
      default = [ ];
      type = listOf attrs;
    };

    kubeVipVersion = mkOption {
      description = "Version of kube-vip to deploy.";
      type = str;
    };

    loadBalance = mkOption {
      description = "Enable kube-vip load balancing functionality.";
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.address != null && cfg.address != "";
        message = "services.kubernetes.kube-vip.address must be set when kube-vip is enabled.";
      }
      {
        assertion = cfg.interface != null && cfg.interface != "";
        message = "services.kubernetes.kube-vip.interface must be set when kube-vip is enabled.";
      }
    ];

    services.kubernetes.kubelet.manifests = {
      kube-vip = manifest;
    };
  };

}
