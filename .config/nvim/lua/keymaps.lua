vim.g.mapleader = " "

vim.keymap.set("x", "p", [["_dP]], { desc = "Paste over selection without loosing yanked text" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move lines up in visual selection" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent amd keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent amd keep selection" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result is centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result is centered" })

-- Autopair
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "\",", "\"\",<left><left>")
vim.keymap.set("i", "(,", "(),<left><left>")
vim.keymap.set("i", "(;", "();<left><left>")
vim.keymap.set("i", "{,", "{},<left><left>")
vim.keymap.set("i", "/*", "/**/<left><left>")

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle builtin undotree" })

vim.keymap.set('n', "<leader>l", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)

-- Carl: run code skill with current buffer as prompt
vim.keymap.set("n", "<leader>cc", function()
  local tmpfile = vim.fn.tempname() .. ".md"
  vim.fn.writefile(vim.fn.getline(1, "$"), tmpfile)
  vim.cmd("enew")
  vim.fn.termopen("carl code " .. tmpfile, {
    env = { EDITOR = "nvim --server " .. vim.v.servername .. " --remote" },
    cwd = vim.fn.getcwd(),
    on_exit = function()
      vim.fn.delete(tmpfile)
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Carl: run code skill with current buffer as prompt" })

-- Carl: run review skill
vim.keymap.set("n", "<leader>cr", function()
  vim.cmd("enew")
  vim.fn.termopen("carl review", {
    env = { EDITOR = "nvim --server " .. vim.v.servername .. " --remote" },
    cwd = vim.fn.getcwd(),
  })
  vim.cmd("startinsert")
end, { desc = "Carl: run review skill" })
