{
  inputs = {
    srvos.url = "github:numtide/srvos";
    nixpkgs.follows = "srvos/nixpkgs";

    dev-tools = {
      url = "github:boozedog/nix-dev-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # flake-parts = {
    #   url = "github:hercules-ci/flake-parts";
    #   inputs.nixpkgs-lib.follows = "nixpkgs";
    # };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-config = {
      url = "github:boozedog/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "srvos/nixpkgs";
    # };
    # treefmt-nix = {
    #   url = "github:numtide/treefmt-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      srvos,
      agenix,
      dev-tools,
      vscode-server,
      home-manager,
      home-manager-config,
      ...
    }:
    let
      serverModules = [
        srvos.nixosModules.server
        srvos.nixosModules.mixins-terminfo
        agenix.nixosModules.default
        vscode-server.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.david = {
              imports = home-manager-config.homeModuleList ++ [
                home-manager-config.nixvimModule
                ./home.nix
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
            #../modules/supabase-cli.nix
            #../weatherspork
          ];
        };
      };

      # Standalone home-manager configuration
      homeConfigurations.david = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = home-manager-config.homeModuleList ++ [
          home-manager-config.nixvimModule
          ./home.nix
        ];
        extraSpecialArgs = {
          username = "david";
        };
      };

      # Development shell with formatting, linting, LSP
      devShells.aarch64-linux.default = dev-tools.lib.mkDevShell {
        system = "aarch64-linux";
        src = ./.;
        statixIgnore = [ "orbstack.nix" ];
      };

      devShells.aarch64-darwin.default = dev-tools.lib.mkDevShell {
        system = "aarch64-darwin";
        src = ./.;
        statixIgnore = [ "orbstack.nix" ];
      };

      # Formatter
      formatter.aarch64-linux = dev-tools.lib.mkFormatter "aarch64-linux";
      formatter.aarch64-darwin = dev-tools.lib.mkFormatter "aarch64-darwin";
    };
}
