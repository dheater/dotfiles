vim.pack.add({
    "https://github.com/nvim-mini/mini.nvim",
})

require("mini.notify").setup({
    content = {
        format = function(notif)
            return notif.msg
        end,
    },
})

require("mini.cmdline").setup()

-- FIXME: Surrounds are not working
require("mini.surround").setup()

-- FIXME: None of these work. Acts like leader is not working
local MiniPick = require("mini.pick")
MiniPick.setup()
vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini File Picker" })
vim.keymap.set("n", "<leader>ps", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Mini Grep" })
vim.keymap.set("n", "<leader>ph", function() MiniPick.builtin.help() end, { desc = "Mini Help" })
vim.keymap.set("n", "<leader>pk", function() MiniPick.builtin.keymaps() end, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>xx", function() MiniPick.builtin.diagnostics() end, { desc = "Mini Picker Diagnostics" })

require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true,
    }
})

