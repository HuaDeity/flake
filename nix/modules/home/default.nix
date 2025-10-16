{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.modules.shared.default
    ./flox.nix
  ];

  config = {
    home.stateVersion = "25.05";

    nix.extraOptions = ''
      !include access-tokens.conf
    '';
  };
}
