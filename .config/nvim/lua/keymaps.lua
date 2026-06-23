vim.g.mapleader = " "

vim.keymap.set("x", "p", [["_dP]], { desc = "Paste over selection wiot loosing yanked text" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move lines up in visual selection" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent amd keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent amd keep selection" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result is centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result is centered" })

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle builtin undotree" })

vim.keymap.set('n', "<leader>f", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
