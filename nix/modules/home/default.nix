{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.modules.shared.default
    ./flox.nix
    inputs.pkgflow.nixModules.default # Unified nix module (auto-detects context)
  ];

  config = {
    home.stateVersion = "25.05";

    nix.extraOptions = ''
      !include access-tokens.conf
    '';
  };
}
