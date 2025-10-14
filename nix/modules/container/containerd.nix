{ pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [
      containerd
      cni-plugins
      nerdctl
      runc
    ];

    systemd.services.containerd = {
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
        ExecStart = "${pkgs.containerd}/bin/containerd";

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
}
