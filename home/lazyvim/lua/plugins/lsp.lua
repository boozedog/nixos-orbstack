return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable nil_ls (default from lang.nix extra), use nixd instead
        nil_ls = { enabled = false },
        nixd = {},
        bashls = {},
      },
    },
  },
}
