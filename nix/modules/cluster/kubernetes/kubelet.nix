{
  config,
  lib,
  options,
  pkgs,
  ...
}:

with lib;

let
  top = config.services.kubernetes;
  otop = options.services.kubernetes;
  cfg = top.kubelet;

  manifestPath = "kubernetes/manifests";
in
{
  ###### interface
  options.services.kubernetes.kubelet = with lib.types; {

    cni = {
      packages = mkOption {
        description = "List of network plugin packages to install.";
        type = listOf package;
        default = [ ];
      };
    };

    enable = mkEnableOption "Kubernetes kubelet";

    manifests = mkOption {
      description = "List of manifests to bootstrap with kubelet (only pods can be created as manifest entry)";
      type = attrsOf (oneOf [
        attrs
        str
      ]);
      default = { };
    };
  };

  ###### implementation
  config = mkMerge [
    (mkIf cfg.enable {
      systemd.services.kubelet = {
        description = "Kubernetes Kubelet Service";
        documentation = [ "https://kubernetes.io/docs/" ];
        wantedBy = [ "kubernetes.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path =
          with pkgs;
          [
            # gitMinimal
            # openssh
            util-linuxMinimal
            # iproute2
            # ethtool
            # thin-provisioning-tools
            # iptables
            # socat
          ]
          #   ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package
          ++ top.path;
        preStart = ''
          mkdir -p /opt/cni/bin
          # rm /opt/cni/bin/* || true
          ${concatMapStrings (package: ''
            echo "Linking cni package: ${package}"
            ln -fs ${package}/bin/* /opt/cni/bin
          '') cfg.cni.packages}
        '';
        serviceConfig = {
          ExecStartPre = lib.optionalString top.kube-vip.loadBalance "-/sbin/modprobe ip_vs";
          ExecStart = "${top.package}/bin/kubelet";
          Restart = "always";
          StartLimitInterval = 0;
          RestartSec = 10;
        };
      };

      # Always include cni plugins
      services.kubernetes.kubelet.cni.packages = [
        pkgs.cni-plugins
      ];
    })

    (mkIf (cfg.enable && cfg.manifests != { }) {
      environment.etc = mapAttrs' (
        name: manifest:
        let
          format = pkgs.formats.yaml_1_2 { };
        in
        nameValuePair "${manifestPath}/${name}.yaml" {
          source = format.generate "${name}.yaml" manifest;
          mode = "0600";
        }
      ) cfg.manifests;
    })

  ];

  meta.buildDocsInSandbox = false;
}
