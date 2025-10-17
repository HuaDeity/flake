{ lib, options, ... }:
let
  hasChannel = lib.hasAttrByPath [ "nix" "channel" ] options;
  hasOptimise = lib.hasAttrByPath [ "nix" "optimise" ] options;
in
{
  config = {
    nix =
      lib.optionalAttrs hasChannel {
        channel.enable = false;
      }
      // lib.optionalAttrs hasOptimise {
        optimise.automatic = true;
      }
      // {
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
