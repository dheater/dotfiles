vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/nvim-mini/mini.nvim",
})

vim.diagnostic.config({
    enable = true,
    virtual_text = false,
    signs = false,
    underline = false,
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
        "jdtls",
        "pyright",
        "html",
    }
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                globals = {
                    "vim",
                    "MiniExtra",
                }
            }
        }
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

require("mini.surround").setup({
    highlight_duration = 2000,
})

local MiniPick = require("mini.pick")
require("mini.extra").setup()
MiniPick.setup()
vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini file Picker" })
vim.keymap.set("n", "<leader>pb", function() MiniPick.builtin.buffers() end, { desc = "Mini buffer picker" })
vim.keymap.set("n", "<leader>pg", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
    { desc = "Mini grep" })
vim.keymap.set("n", "<leader>ph", function() MiniPick.builtin.help() end, { desc = "Mini Help" })
vim.keymap.set("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>pe", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini picker diagnostics" })
vim.keymap.set("n", "<leader>pd", function() MiniExtra.pickers.lsp({ scope = "declaration" }) end, { desc = "Mini picker code declaration" })
vim.keymap.set("n", "<leader>pi", function() MiniExtra.pickers.lsp({ scope = "definition" }) end, { desc = "Mini picker code implementation" })
vim.keymap.set("n", "<leader>pr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "Mini picker lsp references" })

require("mini.completion").setup({
    lsp_completion = {
        auto_setup = false,
    }
})
