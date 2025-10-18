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
  config = lib.mkIf cfg.enable {
    virtualisation.containerd = {
      args.config = toString containerdConfigChecked;
      settings = {
        version = 3;
        plugins."io.containerd.cri.v1.runtime" = {
          cni.bin_dir = lib.mkOptionDefault "${pkgs.cni-plugins}/bin";
        };
      };
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
        apparmor-utils
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
  };
}
