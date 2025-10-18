{
  inputs,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.modules.shared.system
    inputs.self.modules.cluster.kubernetes
    inputs.self.modules.networking.harmonia
  ];

  config = {
    nix.settings.trusted-users = [ "@admin @administrators" ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = with pkgs; [
      perSystem.system-manager.default
      fish
    ];

    virtualisation.containerd = {
      settings = {
        plugins."io.containerd.cri.v1.images" = {
          registry.config_path = "/etc/containerd/certs.d";
        };
      };
    };

    environment.etc."containerd/certs.d/registry.k8s.io/hosts.toml".text = ''
      [host."k8s.m.daocloud.io"]
        capabilities = ["pull", "resolve"]
    '';

    services.harmonia = {
      enable = true;
      signKeyPaths = [ "/var/lib/harmonia/cache-priv-key.pem" ];
    };
  };
}
