# nixos-orbstack

## update

```sh
ssh orb
cd /Users/david/projects/nixos/orbstack/
nix flake update
```

## build (flake)

```sh
sudo nixos-rebuild test --use-substitutes --flake /Users/david/projects/nixos/orbstack
sudo nixos-rebuild switch --no-reexec --use-substitutes --flake /Users/david/projects/nixos/orbstack
```

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