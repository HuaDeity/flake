{
  inputs,
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.services.kubernetes;
  opt = options.services.kubernetes;

  defaultContainerdSettings = {
    version = 3;

    imports = [ "/etc/containerd/config.d/*.toml" ];

    plugins."io.containerd.cri.v1.images" = {
      pinned_images.sandbox = "registry.k8s.io/pause:latest";
    };

    plugins."io.containerd.cri.v1.runtime" = {
      containerd.runtimes.runc = {
        options.SystemdCgroup = true;
      };
    };
  };
in
{
  imports = [
    ./kubelet.nix
    ./kubeadm.nix
    ./kube-vip.nix
    inputs.self.modules.virtualisation.containerd
  ];

  ###### interface

  options.services.kubernetes = {
    roles = lib.mkOption {
      description = ''
        Kubernetes role that this machine should take.

        Master role will enable etcd, apiserver, scheduler, controller manager
        addon manager, flannel and proxy services.
        Node role will enable flannel, docker, kubelet and proxy services.
      '';
      default = [ ];
      type = lib.types.listOf (
        lib.types.enum [
          "init"
          "master"
          "node"
        ]
      );
    };

    package = lib.mkPackageOption pkgs "kubernetes" { };

    path = lib.mkOption {
      description = "Packages added to the services' PATH environment variable. Both the bin and sbin subdirectories of each package are added.";
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  ###### implementation

  config = lib.mkMerge [
    {
      environment.systemPackages = [
        pkgs.kubernetes
        pkgs.kubernetes-helm
        pkgs.cilium-cli
      ];
      services.kubernetes.kubeadm.enable = lib.mkDefault true;
      services.kubernetes.kubelet.enable = lib.mkDefault true;
    }

    (lib.mkIf (lib.elem "master" cfg.roles || lib.elem "init" cfg.roles) {
      services.kubernetes.kubeadm.taints = lib.mkIf (lib.elem "node" cfg.roles) [ ];
      services.kubernetes.kube-vip.enable = lib.mkDefault true;
    })

    # (lib.mkIf (lib.elem "node" cfg.roles) {
    # })

    (lib.mkIf (cfg.kubelet.enable) {
      environment.systemPackages = [
        pkgs.cri-tools
      ];
      virtualisation.containerd = {
        enable = lib.mkDefault true;
        settings = lib.mapAttrsRecursive (name: lib.mkDefault) defaultContainerdSettings;
      };
    })
  ];

  meta.buildDocsInSandbox = false;
}
