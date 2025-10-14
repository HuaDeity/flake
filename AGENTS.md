# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` is the single entrypoint; it wires inputs and exports modules with the `inputs.blueprint` helper.
- `nix/hosts/<Host>/` holds host profiles: `system-configuration.nix` or `darwin-configuration.nix` plus per-user `home-configuration.nix`.
- `nix/modules/` contains reusable building blocks (e.g., `container/` for Kubernetes bits, `home/` for shared Home Manager rules, `nixos/` for base NixOS defaults).
- Flox manifests live under `default/.flox/`; keep the TOML package manifest in sync with the companion mapping in `default/mapping.toml`.

## Build, Test, and Development Commands
- Run `nix flake check` before proposing changes; it evaluates all hosts, modules, and devshells.
- Build Linux hosts locally with `nix build .#nixosConfigurations.Lab103.config.system.build.toplevel`; follow with `sudo nixos-rebuild switch --flake .#Lab103` on the target.
- Update the macOS host via `darwin-rebuild switch --flake .#ViMacBook`.
- Refresh user environments using `home-manager switch --flake .#wangyizun@Lab103` (adapt the suffix to the desired `<user>@<host>`).

## Coding Style & Naming Conventions
- Prefer the standard 2-space Nix indentation and keep attribute sets alphabetised when practical.
- Format Nix code with `nix fmt` (powered by `nixfmt-rfc-style` from the Flox env); ensure imports remain one per line.
- Use descriptive attribute names (e.g., `mkNixPackages`, `home.packages`) mirroring the structure already established in `nix/lib/default.nix`.
- Check in generated derivations only when reproducible; never commit machine-specific paths from `/nix/store`.

## Testing Guidelines
- Treat `nix flake check` as the minimum gate; add `nix eval .#<output>` when validating new attributes.
- Exercise system deployments with `nixos-rebuild test --flake .#Lab103` or `darwin-rebuild check --flake .#ViMacBook` before switching.
- For container modules, run `nix build .#modules.container.kubernetes` to confirm the YAML renders, then validate against `kubeadm` in a sandbox cluster.

## Commit & Pull Request Guidelines
- The repository is managed with Jujutsu (`.jj/`); follow the existing short, imperative subject style scoped by area (e.g., `nixos: enable containerd`).
- Use bodies for rationale and rollout notes, wrapping at ~72 characters; list follow-ups with `-` bullets.
- Group related refactors into one change set; leverage `jj squash` instead of force-pushing.
- Pull requests should link supporting issues, call out affected hosts, and include any screenshots or logs that demonstrate successful rebuilds.

## Security & Configuration Tips
- Secrets and tokens belong in `~/.config/nix/access-tokens.conf`, which is referenced via `nix.extraOptions`—never commit credentials.
- When editing Homebrew mappings, update both `default/mapping.toml` and the Flox manifest to keep macOS parity with Nix packages.
- Validate third-party inputs (e.g., overlays, caches) before adding them to `flake.nix`, and document the motivation in the PR body.
