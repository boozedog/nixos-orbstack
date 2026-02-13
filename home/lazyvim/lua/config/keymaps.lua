-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Quick file finder with -
vim.keymap.set("n", "-", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
