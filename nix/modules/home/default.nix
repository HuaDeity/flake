{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.modules.shared.default
    inputs.pkgflow.homeModules.pkgflow
  ];

  config = {
    home.stateVersion = "25.05";

    programs.home-manager.enable = true;
  };
}
