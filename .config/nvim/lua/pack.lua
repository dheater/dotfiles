vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/folke/snacks.nvim",
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

require("mini.diff").setup({
    mappings = {
        apply = "<leader>ga",
        reset = "<leader>gr",
        goto_next = "<leader>gn",
        goto_prev = "<leader>gp",
    }
})
vim.keymap.set("n", "<leader>gt", function() MiniDiff.toggle_overlay() end, { desc = "Toggle git diff" })

require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true,
    }
})

local Snacks = require("snacks")
Snacks.setup({
    notifier = {},
    indent = {},
    terminal = {
        win = {
            position = "float",
            height = 0.9,
            width = 0.9,
            border = "single",
        },
    },
    picker = {
        matcher = {
            frecency = true,
        },
        win = {
            input = {
                keys = {
                    ["d"] = "bufdelete",
                },
                b = {
                    minipairs_disable = true,
                },
            },
        },
    },
})

vim.cmd([[au FileType snacks_picker_input lua vim.b.minicompletion_disable = true]])
vim.keymap.set("n", "<Leader>f", function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set("n", "<Leader>b", function()
    Snacks.picker.buffers()
end, { desc = "Show buffers" })
vim.keymap.set("n", "<Leader>g", function() Snacks.picker.grep() end, { desc = "grep" })
vim.keymap.set("n", "<Leader>k", function() Snacks.picker.keymaps() end, { desc = "Show keymaps" })
vim.keymap.set("n", "<Leader>m", function() Snacks.picker.marks() end, { desc = "Marks" })
vim.keymap.set("n", "<Leader>u", function() Snacks.picker.undo() end, { desc = "Undo History" })
vim.keymap.set("n", "<Leader>d", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set("n", "<Leader>s", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<Leader>ss", function() Snacks.picker.lsp_workspace_symbols() end,
    { desc = "LSP Workspace Symbols" })
vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })

-- Terminal
vim.keymap.set({ "n", "t" }, "<C-t>", function() Snacks.terminal.toggle() end, { desc = "Toggle terminal" })

-- Git
vim.keymap.set("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function()
    Snacks.picker.git_status()
    vim.cmd.stopinsert()
end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })
