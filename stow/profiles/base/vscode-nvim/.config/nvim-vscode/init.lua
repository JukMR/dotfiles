vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.laststatus = 0

vim.opt.runtimepath:append(vim.fn.expand("$HOME") .. "/.config/nvim")
require("shared.mappings").setup()

local function vscode_action(action)
  vim.fn["vscode#call"](action)
end

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "gd", function() vscode_action("editor.action.revealDefinition") end)
vim.keymap.set("n", "gr", function() vscode_action("editor.action.goToReferences") end)
vim.keymap.set("n", "<leader>f", function() vscode_action("editor.action.formatDocument") end)
vim.keymap.set("n", "K", function() vscode_action("editor.action.showHover") end)
