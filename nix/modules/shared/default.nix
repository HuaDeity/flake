{
  pkgs,
  lib,
  options,
  ...
}:
{
  imports = [
    ./options.nix
    ./pkgflow.nix
  ];

  config =
    let
      # Check if we're in a home-manager context (which has submoduleSupport option)
      # If not in home-manager, we should apply the system-level nix settings
      isHomeManager = lib.hasAttrByPath [ "submoduleSupport" "enable" ] options;
    in
    lib.optionalAttrs (!isHomeManager) {
      nix.package = pkgs.nix;

      # This part is new. It only adds the 'nix.gc' attribute set if the
      # option has been declared somewhere in the module system.
      nix.gc = lib.mkIf (lib.hasAttrByPath [ "nix" "gc" ] options) {
        automatic = true;
      };
    };
}
