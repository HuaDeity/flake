# Repository Guidelines

## Project Structure & Module Organization
This flake manages macOS and Linux machines. `flake.nix` declares inputs and delegates evaluation to the `nix/` prefix. Host-specific definitions live in `nix/hosts/<HostName>/`, where each directory bundles the system entry point plus any host data (e.g. `config.yaml`, `kube-vip.yaml`). Shared modules are split by target: `nix/modules/darwin`, `nix/modules/nixos`, `nix/modules/home`, and `nix/modules/container`. Common helpers (primary user setup, manifest-driven packages) live beside these modules rather than under `nix/lib`. Keep generated symlinks such as `result` out of commits. Additional module notes live under `docs/`, e.g. `docs/manifest-packages.md` for Flox manifest handling.

## Build, Test, and Development Commands
Use `nix develop` to enter the repo’s toolchain with `nixfmt`, `jj`, and other declared utilities. Validate the configuration with `nix flake check`, which evaluates every output and runs defined checks. Build concrete systems before deploying: `nix build .#darwinConfigurations.ViMacBook.system` for the macOS host, and `nix build .#nixosConfigurations.Lab103.config.system.build.toplevel` for the Lab103 NixOS deployment. To preview a Home Manager profile, run `nix build .#homeConfigurations.ViMacBook.activationPackage` and inspect the resulting `result` link.

## Coding Style & Naming Conventions
Format all `.nix` files with `nix fmt` (treefmt + `nixfmt-rfc-style`). Default to two-space indentation and align attribute sets so related keys stay readable. Use hyphenated filenames for entry points (`darwin-configuration.nix`) and rely on module wiring (`flake.modules.darwin.primaryUser`, `flake.modules.home.manifestPackages`, `flake.modules.shared.manifest`). Attribute names should remain lowerCamelCase unless interacting with upstream modules. Keep TOML manifests (`nix/modules/darwin/config/mapping.toml`) sorted alphabetically by package key, set a repo-wide manifest path via `shared.manifest.file`, and flip `home.manifestPackages.outputs.system.enable = true` when the shared manifest should feed system packages.

## Testing Guidelines
`nix flake check` is the baseline gate; run it before every PR. When adding modules, also run a targeted evaluation such as `nix eval .#darwinConfigurations.ViMacBook.options` or the analogous `nixosConfigurations` command to confirm option resolution. For container modules, ensure referenced manifests exist and that Kubernetes YAML passes `kubectl apply --dry-run=client` out-of-band. Capture any host-specific caveats in README snippets under `nix/hosts/<HostName>/`.

## Commit & Pull Request Guidelines
Follow the short imperative style used in the log (`Add kube-vip config`, `Refactor for nix modules`). Reference the affected module or host in the subject, and avoid multi-topic commits. Pull requests should include: a concise summary, before/after context for user-facing changes, confirmation that `nix flake check` and relevant builds succeeded, and links to any tracking issues or deployment notes. Screenshots are only required when a change alters rendered assets (rare here).
