vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/nvim-mini/mini.nvim",
})
 
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "ts_ls",
        "clangd",
        "rust_analyzer",
        "marksman",
        "just",
        "ols",
        "zls",
        "jsonls",
        "java_languae_server",
        "pyright",
        "html",
    }
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

local MiniPick = require("mini.pick")
MiniPick.setup()
vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini file Picker" })
vim.keymap.set("n", "<leader>pb", function() MiniPick.builtin.buffers() end, { desc = "Mini buffer picker" })
vim.keymap.set("n", "<leader>ps", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Mini grep" })
vim.keymap.set("n", "<leader>ph", function() MiniPick.builtin.help() end, { desc = "Mini Help" })
vim.keymap.set("n", "<leader>pk", function() MiniPick.builtin.keymaps() end, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>xx", function() MiniPick.builtin.diagnostics() end, { desc = "Mini picker diagnostics" })

require("mini.completion").setup({
    lsp_completion = {
       auto_setup = false,
    }
})

