{ config, lib, ... }:

let
  cfg = config.darwin.primaryUser;
in
{
  options.darwin.primaryUser = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "huadeity";
      description = "Short username for the primary local account.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 501;
      description = "Numeric user identifier to assign to the account.";
    };

    home = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Home directory for the user. Defaults to `/Users/<name>` when unset.
      '';
    };

    hidden = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Mark the user as hidden from the macOS login UI.";
    };
  };

  config =
    let
      homeDir =
        if cfg.home != null then cfg.home else "/Users/${cfg.name}";
    in
    {
      assertions = [
        {
          assertion = cfg.name != "";
          message = "Set darwin.primaryUser.name when using the primary user module.";
        }
      ];

      users.knownUsers = [ cfg.name ];

      users.users.${cfg.name} = {
        name = cfg.name;
        home = homeDir;
        isHidden = cfg.hidden;
        uid = cfg.uid;
      };

      system.primaryUser = cfg.name;
    };
}
