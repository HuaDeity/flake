# Manifest Packages Module

The `flake.modules.home.manifestPackages` module converts a Flox manifest into Nix package lists so the same package declaration can feed Home Manager and system-level profiles.

## Inputs
- `manifestFile`: Path to the Flox `manifest.toml`. Defaults to `config.shared.manifest.file`, provided by `flake.modules.shared.manifest`. Set to `null` to disable the module.
- `requireSystemMatch` (bool, default `false`): When `true`, only entries that declare the current `systems` list are installed. Leave at the default to include packages that omit the field.
- `outputs.home.enable` (bool, default `true`): Emit the resolved set to `home.packages`.
- `outputs.system.enable` (bool, default `false`): Emit the resolved set to `environment.systemPackages`.

## Resolution Rules
1. **Regular packages** (`pkg-path` entries) are resolved through `pkgs` using dotted attribute lookup.
2. **Flake packages** (`flake` entries) are resolved from the originating flake input via `flake.inputs.<name>.packages.${pkgs.system}.default`. Ensure the upstream input exposes a `default` package for each target system.
3. Packages with `systems` filters follow the current host’s `pkgs.system` and the `requireSystemMatch` toggle.
4. `null` results are dropped automatically, allowing optional packages to fail open.

## Usage Examples

```nix
# Home Manager only (default)
{
  imports = [ flake.modules.home.manifestPackages ];

  shared.manifest.file = ./alternate-manifest.toml; # Optional override
}
```

```nix
# Feed both Home Manager and the system profile on Linux
{
  imports = [ flake.modules.home.manifestPackages ];

  home.manifestPackages = {
    outputs.system.enable = true;
  };
}
```

Outside this module you can still access blueprint’s `perSystem` helper (e.g. `perSystem.system-manager.default`) as shown in `nix/hosts/Lab103/system-configuration.nix`.
