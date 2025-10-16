{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.harmonia;
  format = pkgs.formats.toml { };

  signKeyPaths = cfg.signKeyPaths ++ lib.optional (cfg.signKeyPath != null) cfg.signKeyPath;
  # credentials = lib.imap0 (i: signKeyPath: {
  #   id = "sign-key-${builtins.toString i}";
  #   path = signKeyPath;
  # }) signKeyPaths;
in
{
  options = {
    services.harmonia = {
      enable = lib.mkEnableOption "Harmonia: Nix binary cache written in Rust";

      signKeyPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "DEPRECATED: Use `services.harmonia.signKeyPaths` instead. Path to the signing key to use for signing the cache";
      };

      signKeyPaths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = "Paths to the signing keys to use for signing the cache";
      };

      package = lib.mkPackageOption pkgs "harmonia" { };

      settings = lib.mkOption {
        inherit (format) type;
        default = { };
        description = ''
          Settings to merge with the default configuration.
          For the list of the default configuration, see <https://github.com/nix-community/harmonia/tree/master#configuration>.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = signKeyPaths != [ ];
        message = "services.harmonia.signKeyPaths must not be empty when harmonia is enabled";
      }
    ];

    warnings = lib.optional (
      cfg.signKeyPath != null
    ) "`services.harmonia.signKeyPath` is deprecated, use `services.harmonia.signKeyPaths` instead";
    nix.settings.extra-allowed-users = [ "harmonia" ];

    systemd.services.harmonia = {
      description = "harmonia binary cache service";

      requires = [ "nix-daemon.socket" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        CONFIG_FILE = format.generate "harmonia.toml" cfg.settings;
        # Pass signing key paths directly (compatible with older systemd without LoadCredential)
        SIGN_KEY_PATHS = lib.concatStringsSep " " signKeyPaths;
        # SIGN_KEY_PATHS = lib.strings.concatMapStringsSep " " (
        #   credential: "%d/${credential.id}"
        # ) credentials;
        # Note: it's important to set this for nix-store, because it wants to use
        # $HOME in order to use a temporary cache dir. bizarre failures will occur
        # otherwise
        HOME = "/run/harmonia";
      };

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        User = "harmonia";
        Group = "harmonia";
        Restart = "on-failure";
        PrivateUsers = true;
        DeviceAllow = [ "" ];
        UMask = "0066";
        RuntimeDirectory = "harmonia";
        # LoadCredential = builtins.map (credential: "${credential.id}:${credential.path}") credentials;
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        CapabilityBoundingSet = "";
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectHostname = true;
        ProtectClock = true;
        RestrictRealtime = true;
        MemoryDenyWriteExecute = true;
        # ProcSubset = "pid";
        # ProtectProc = "invisible";
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        LockPersonality = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        LimitNOFILE = 65536;
      };
    };
  };
}
