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
        keepalived
        kubernetes
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
      etc."keepalived/keepalived.conf".text = ''
        global_defs {
          # Name of VIP Instance
          router_id KubernetesVIP

          # Enable SNMP Monitoring (Optional)
          # enable_traps
        }
        vrrp_instance APIServerVIP {
          # Interface to bind to
          interface ens192

          # This should be set to MASTER on the first node and BACKUP on the other two
          state MASTER
          # This should be 50+ lower on the other two nodes to enable the lead election
          priority 100

          # Address of this particular node
          mcast_src_ip $node_IP

          # A unique ID if more than one service is being defined
          virtual_router_id 61
          advert_int 1
          nopreempt

          # Authentication for keepalived to speak with one another
          authentication {
              auth_type PASS
              auth_pass $bloody_secure_password
          }

          # Other Nodes in Cluster
          unicast_peer {
              $other_node_IP
              $other_node_IP
          }

          # Kubernetes Virtual IP
          virtual_ipaddress {
              10.0.0.100/24
          }

          # Health check function (optional)
          #track_script {
          #    APIServerProbe
          #}
        }
        vrrp_instance VI_1 {
            state BACKUP
            interface eth0
            virtual_router_id 51
            priority 100
            advert_int 1
            authentication {
                auth_type PASS
                auth_pass mypassword
            }
            virtual_ipaddress {
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
    };
  };
}
