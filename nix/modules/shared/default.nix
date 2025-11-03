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
    in
    lib.optionalAttrs (!isHomeManager) {
      nix.package = pkgs.nix;
    }
    // lib.optionalAttrs (!isHomeManager && hasGc) {
      nix.gc.automatic = true;
    }
    // {
      pkgflow.manifestFile = "${inputs.self}/${config.self.floxDir}/env/manifest.toml";
    };
}
