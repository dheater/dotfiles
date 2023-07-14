-- Remaps
-- Shout out to The Primeagan for many of these!
--
local default_opts = { noremap = true, silent = true }

vim.g.mapleader = " "

-- netRRW
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move stuff around
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- keep cursor in place when splicing lines
vim.keymap.set("n", "J", "mzJ`z")

-- indent/dedent
vim.keymap.set("v", ">", "<gv", default_opts)
vim.keymap.set("v", "<", ">gv", default_opts)

-- keep cursor centered on up/down/search
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste without replace
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yank to system clipboard: asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
-- delete to void
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- blackhole Q
vim.keymap.set("n", "Q", "<nop>")

-- format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- replace the word I am on
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

