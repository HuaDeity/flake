{ pkgs, ... }:
{
  config = {
    nix = {
      package = pkgs.nix;

      settings = {
        accept-flake-config = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://cache.flox.dev"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
        ];
        trusted-public-keys = [
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        ];
        use-xdg-base-directories = true;
      };
    };

    nixpkgs.config.allowUnfree = true;
  };
}
