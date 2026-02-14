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

# update individual packages
mise run update:td
mise run update:sidecar

# pin a specific commit
./scripts/update-td.sh <commit-sha>
./scripts/update-sidecar.sh <commit-sha>
```

If a build fails with a vendorHash mismatch, copy the expected hash from
the error and replace `vendorHash` in the relevant `packages/*.nix` file, then rebuild.

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
