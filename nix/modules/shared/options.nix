{
  lib,
  ...
}:
{
  options = {
    self = {
      flakeDir = lib.mkOption {
        type = lib.types.str;
        default = ".config/flake";
        description = "Relative path to the flake directory";
        readOnly = true;
      };
      floxDir = lib.mkOption {
        type = lib.types.str;
        default = "nix/modules/home/.flox";
        description = "Relative path to the flox directory";
        readOnly = true;
      };
    };
  };
}
