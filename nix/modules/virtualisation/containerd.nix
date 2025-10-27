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

    (lib.mkIf (cfg.enable && cfg.settings != { }) {
      environment.etc = {
        "containerd/config.d/99-nvidia.toml".text = ''
          version = 3

          [plugins]

            [plugins."io.containerd.cri.v1.runtime"]

              [plugins."io.containerd.cri.v1.runtime".containerd]

                [plugins."io.containerd.cri.v1.runtime".containerd.runtimes]

                  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.nvidia]
                    runtime_type = 'io.containerd.runc.v2'

                    [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.nvidia.options]
                      BinaryName = "/usr/bin/nvidia-container-runtime"
                      SystemdCgroup = true

                  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc]

                    [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc.options]
                      SystemdCgroup = true
        '';
      };
    })
  ];
}
