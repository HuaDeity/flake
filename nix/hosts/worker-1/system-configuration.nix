{ inputs, ... }:
{
  imports = [
    inputs.self.modules.cluster.default
  ];
  config = {
    nix.settings.substituters = [ "http://192.168.103.57:5000" ];
    nix.settings.trusted-public-keys = [
      "harmonia-cache:l0LYxhBdXd9HN49z32harQ0VuxichxPcKbs6u5gna3o="
    ];

    services.kubernetes = {
      roles = [
        "node"
      ];
    };
  };
}
