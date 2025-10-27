{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.virtualisation.containerd;

  configFile = settingsFormat.generate "containerd.toml" cfg.settings;

  containerdConfigChecked =
    pkgs.runCommand "containerd-config-checked.toml"
      {
        nativeBuildInputs = [ pkgs.containerd ];
      }
      ''
        containerd -c ${configFile} config dump >/dev/null
        ln -s ${configFile} $out
      '';

  settingsFormat = pkgs.formats.toml { };

  # Generate registry mirror hosts.toml files
  registryConfigDir = pkgs.runCommand "containerd-registry-config" { } ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        registry: mirrors:
        let
          hostsConfig = lib.listToAttrs (
            map (mirror: {
              name = "host.\"${mirror.host}\"";
              value = {
                capabilities = mirror.capabilities;
              };
            }) mirrors
          );
          hostsFile = settingsFormat.generate "hosts.toml" hostsConfig;
        in
        ''
          mkdir -p $out/${registry}
          ln -s ${hostsFile} $out/${registry}/hosts.toml
        ''
      ) cfg.registryMirrors
    )}
  '';
in
{
  options.virtualisation.containerd = with lib.types; {
    enable = lib.mkEnableOption "containerd container runtime";

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Verbatim lines to add to containerd.toml
      '';
    };

    args = lib.mkOption {
      default = { };
      description = "extra args to append to the containerd cmdline";
      type = attrsOf str;
    };

    nvidia = {
      enable = lib.mkEnableOption "NVIDIA container runtime support";
    };

    registryMirrors = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              host = lib.mkOption {
                type = lib.types.str;
                description = "Mirror host URL";
              };
              capabilities = lib.mkOption {
                type = lib.types.listOf (lib.types.enum [
                  "pull"
                  "resolve"
                  "push"
                ]);
                default = [
                  "pull"
                  "resolve"
                ];
                description = "Capabilities supported by this mirror";
              };
            };
          }
        )
      );
      default = { };
      description = ''
        Registry mirror configuration. Maps registry hostnames to lists of mirror hosts.
        Example:
        {
          "registry.k8s.io" = [
            { host = "k8s.m.daocloud.io"; }
          ];
          "docker.io" = [
            { host = "docker.m.daocloud.io"; }
          ];
        }
      '';
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.containerd = {
        args.config = toString containerdConfigChecked;
      };

      environment.systemPackages = [
        pkgs.containerd
        pkgs.nerdctl
      ];

      systemd.services.containerd = {
        description = "containerd - container runtime";
        documentation = [ "https://containerd.io" ];
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          # "local-fs.target"
          "dbus.service"
        ];
        path = with pkgs; [
          containerd
          runc
          apparmor-parser
          # iptables
        ];
        # ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package;
        serviceConfig = {
          ExecStartPre = "-/sbin/modprobe overlay";
          ExecStart = ''${pkgs.containerd}/bin/containerd ${
            lib.concatStringsSep " " (lib.cli.toGNUCommandLine { } cfg.args)
          }'';
          Delegate = "yes";
          KillMode = "process";
          Type = "notify";
          Restart = "always";
          RestartSec = "10";

          # "limits" defined below are adopted from upstream: https://github.com/containerd/containerd/blob/master/containerd.service
          LimitNPROC = "infinity";
          LimitCORE = "infinity";
          TasksMax = "infinity";
          OOMScoreAdjust = "-999";

          StateDirectory = "containerd";
          RuntimeDirectory = "containerd";
          RuntimeDirectoryPreserve = "yes";
        };
        unitConfig = {
          StartLimitBurst = "16";
          StartLimitIntervalSec = "120s";
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.nvidia.enable) {
      virtualisation.containerd.settings = {
        plugins."io.containerd.cri.v1.runtime" = {
          containerd = {
            runtimes = {
              nvidia = {
                runtime_type = "io.containerd.runc.v2";
                options = {
                  BinaryName = "/usr/bin/nvidia-container-runtime";
                  SystemdCgroup = true;
                };
              };
              runc = {
                options = {
                  SystemdCgroup = true;
                };
              };
            };
          };
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.registryMirrors != { }) {
      virtualisation.containerd.settings = {
        plugins."io.containerd.cri.v1.images" = {
          registry.config_path = toString registryConfigDir;
        };
      };
    })
  ];
}
