{
  inputs = {
    srvos.url = "github:numtide/srvos";
    nixpkgs.follows = "srvos/nixpkgs";

    # dev-tools = {
    #   url = "github:boozedog/nix-dev-tools";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-config = {
      url = "github:boozedog/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      srvos,
      #dev-tools,
      vscode-server,
      home-manager,
      home-manager-config,
      agenix,
      ...
    }:
    let
      system = "aarch64-linux";

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Local packages
      claude-code = pkgs.callPackage ./packages/claude-code.nix { };
      sidecar = pkgs.callPackage ./packages/sidecar.nix { };
      td = pkgs.callPackage ./packages/td.nix { };

      serverModules = [
        srvos.nixosModules.server
        srvos.nixosModules.mixins-terminfo
        vscode-server.nixosModules.default
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.david = {
              imports = [
                home-manager-config.homeModules.default
                home-manager-config.homeModules.shells
                ./home
                ./home/claude-code.nix
                ./home/lazyvim.nix
                ./home/zellij.nix
              ];
            };
            extraSpecialArgs = {
              username = "david";
            };
          };
        }
      ];
    in
    {
      nixosConfigurations = {
        orbstack = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs self; };
          modules = serverModules ++ [
            ./configuration.nix
            #disko.nixosModules.disko
            #../modules/docker.nix
            #../modules/k3s.nix
            #../modules/matomo.nix
            #../modules/nftables.nix
            ./modules/openvscode-server.nix
            #../modules/supabase-cli.nix
            ./modules/tailscale.nix
            #../weatherspork
            {
              environment.systemPackages = [
                agenix.packages.${system}.default
                claude-code
                sidecar
                td
              ];
            }
          ];
        };
      };

      # Standalone home-manager configuration
      homeConfigurations.david = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          home-manager-config.homeModules.default
          home-manager-config.homeModules.shells
          ./home
          ./home/claude-code.nix
          ./home/lazyvim.nix
          ./home/zellij.nix
        ];
        extraSpecialArgs = {
          username = "david";
        };
      };

      # # Development shell with formatting, linting, LSP
      # devShells.aarch64-linux.default = dev-tools.lib.mkDevShell {
      #   system = "aarch64-linux";
      #   src = ./.;
      # };

      # devShells.aarch64-darwin.default = dev-tools.lib.mkDevShell {
      #   system = "aarch64-darwin";
      #   src = ./.;
      # };
    };
}
