{
  inputs,
  config,
  pkgs,
  lib,
  options,
  ...
}:
{
  imports = [
    ./options.nix
  ];

  config =
    let
      isHomeManager = lib.hasAttrByPath [ "submoduleSupport" "enable" ] options;
      hasGc = lib.hasAttrByPath [ "nix" "gc" ] options;
      hasPkgflow = lib.hasAttrByPath [ "pkgflow" ] options;
    in
    lib.mkMerge [
      # Conditional nix.package based on submoduleSupport
      (lib.mkIf (!isHomeManager || !config.submoduleSupport.enable) {
        nix.package = pkgs.nix;
      })

      # Conditional nix.gc
      (lib.mkIf (!isHomeManager || !config.submoduleSupport.enable) (
        lib.optionalAttrs hasGc {
          nix.gc.automatic = true;
        }
      ))

      (lib.optionalAttrs hasPkgflow {
        pkgflow = {
          pkgs.nixpkgs = [ "brew" ];
          pkgs.flakes = [ "brew" ];
          manifestFiles = [ "${inputs.self}/${config.self.homeModuleDir}/shared.toml" ];
        };
      })
    ];
}
