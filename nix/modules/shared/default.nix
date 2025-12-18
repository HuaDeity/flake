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
    inputs.flox-manifest-fetch.flakeModules.floxManifests
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
      (lib.mkIf ((!isHomeManager || !config.submoduleSupport.enable)) (
        lib.optionalAttrs hasGc {
          nix.gc.automatic = true;
        }
      ))

      (lib.optionalAttrs hasPkgflow {
        pkgflow = {
          pkgs.nixpkgs = [ "brew" ];
          manifestFiles = map (m: "${inputs.self}/${m}") config.floxManifests.manifests;
        };
        floxManifests = {
          enable = true;
          environments = [ "default" ];
          cacheDir = ".flox-manifests";
        };
      })
    ];
}
