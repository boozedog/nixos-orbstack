-- Disable Mason — LSP servers and tools are managed by Nix
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
}
