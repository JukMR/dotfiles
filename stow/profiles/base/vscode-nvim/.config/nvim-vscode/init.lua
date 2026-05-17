vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.laststatus = 0

local function vscode_action(action)
  vim.fn["vscode#call"](action)
end

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "gd", function() vscode_action("editor.action.revealDefinition") end)
vim.keymap.set("n", "gr", function() vscode_action("editor.action.goToReferences") end)
vim.keymap.set("n", "<leader>f", function() vscode_action("editor.action.formatDocument") end)
vim.keymap.set("n", "K", function() vscode_action("editor.action.showHover") end)

-- Shared mappings (from mapping.lua)
-- Visual Mode
vim.keymap.set("v", "<M-up>", ":m '<-2<CR>gv=gv", { desc = "Move selection one line up" })
vim.keymap.set("v", "<M-down>", ":m '>+1<CR>gv=gv", { desc = "Move selection one line down" })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection one line up" })
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection one line down" })
vim.keymap.set("v", "<Leader>y", '"+y', { desc = "Copy to system clipboard (+)" })
vim.keymap.set("v", "<Leader>c", '"+y', { desc = "Copy to system clipboard (+)" })
vim.keymap.set("v", "<Leader>x", '"+ygv"_d', { desc = "Cut to system clipboard (+)" })
vim.keymap.set("v", "<Leader>j", "!jq .<CR>", { desc = "Format selected JSON with jq" })

-- Normal Mode
vim.keymap.set("n", "<Leader>s", ":%s/\\s\\+$//e<CR>", { desc = "Remove all trailing whitespaces" })
vim.keymap.set("n", "<Leader>S", ":noa w<CR>", { desc = "Save file without applying formatting" })
vim.keymap.set("n", "<Leader>a", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<M-up>", "ddkP", { desc = "Move line one line up" })
vim.keymap.set("n", "<M-down>", "ddp", { desc = "Move line one line down" })
vim.keymap.set("n", "<M-k>", "ddkP", { desc = "Move line one line up" })
vim.keymap.set("n", "<M-j>", "ddp", { desc = "Move line one line down" })
vim.keymap.set("n", "<Leader>z", ":set wrap!<CR>", { desc = "toggle wrap" })
vim.keymap.set("n", "<M-z>", ":set wrap!<CR>", { desc = "toggle wrap" })
vim.keymap.set("n", "<Leader>y", '"+y', { desc = "Copy to system clipboard (+)" })
vim.keymap.set("n", "<Leader>x", '"+ygv"_d', { desc = "Cut to system clipboard (+)" })
vim.keymap.set("n", "<Leader>j", ":%!jq .<CR>", { desc = "Format full json with jq" })
vim.keymap.set("n", "<C-S-i>", ":%!jq .<CR>", { desc = "Format full json with jq" })
vim.keymap.set("n", "n", "nzzzv:set hlsearch<CR>", { desc = "When searching for next term center screen" })
vim.keymap.set("n", "N", "Nzzzv:set hlsearch<CR>", { desc = "When searching for prev term center screen" })
vim.keymap.set("n", "<Leader>\\", ":set list!<CR>", { desc = "Toggle list" })

-- Insert Mode
vim.keymap.set("i", "<M-d>", "<C-o>dw", { desc = "Delete forward word" })
vim.keymap.set("i", "<C-a>", "<C-o>0", { desc = "Go to beginning of the line" })
vim.keymap.set("i", "<C-e>", "<C-o>$", { desc = "Go to end of line" })

-- Visual-only mode (no select mode)
vim.keymap.set("x", "<Leader>p", '"_dP', { desc = "Paste without overwriting register" })