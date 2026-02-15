# nixos-orbstack

## update

```sh
ssh orb
cd ~/projects/nixos/orbstack/
nix flake update
```

## build (flake)

```sh
nix flake check
sudo nixos-rebuild switch --no-reexec --use-substitutes --flake .
```

## mise tasks

```sh
# update all packages and rebuild NixOS
mise run update:all

# update td individually
mise run update:td

# pin td to a specific commit
./scripts/update-td.sh <commit-sha>

# update sidecar (fetched as a flake input)
nix flake update sidecar
```

If a build fails with a vendorHash mismatch, copy the expected hash from
the error and replace `vendorHash` in `packages/td.nix`, then rebuild.

## build (non-flake)

```sh
sudo nixos-rebuild test -I nixos-config=/Users/david/projects/nixos/orbstack/configuration.nix
sudo nixos-rebuild switch -I nixos-config=/Users/david/projects/nixos/orbstack/configuration.nix
```

## initial setup

```sh
ssh orb
nix-shell -p git
cd /Users/david/projects/nixos/orbstack/
nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes
```

<!-- markdownlint-disable-file MD013 -->
