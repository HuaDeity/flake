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
      homeModuleDir = lib.mkOption {
        type = lib.types.str;
        default = "nix/modules/home";
        description = "Relative path to the home modules directory";
        readOnly = true;
      };
    };
  };
}
