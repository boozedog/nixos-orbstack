{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # Build tools
      gcc
      gnumake
      nodejs
      tree-sitter

      # LazyVim tools
      lazygit
      fd

      # LSP servers
      nixd
      lua-language-server
      vtsls
      vscode-langservers-extracted
      yaml-language-server
      bash-language-server
      pyright
      ruff

      # Formatters / linters
      nixfmt
      statix
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".source = ./lazyvim/init.lua;
    "nvim/lua/config/lazy.lua".source = ./lazyvim/lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./lazyvim/lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./lazyvim/lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./lazyvim/lua/config/autocmds.lua;
    "nvim/lua/plugins/colorscheme.lua".source = ./lazyvim/lua/plugins/colorscheme.lua;
    "nvim/lua/plugins/mason.lua".source = ./lazyvim/lua/plugins/mason.lua;
    "nvim/lua/plugins/lsp.lua".source = ./lazyvim/lua/plugins/lsp.lua;
    "nvim/lua/plugins/formatting.lua".source = ./lazyvim/lua/plugins/formatting.lua;
    "nvim/lua/plugins/linting.lua".source = ./lazyvim/lua/plugins/linting.lua;
  };
}
