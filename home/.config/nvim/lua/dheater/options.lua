local options = {
	expandtab = true,
	mouse = "a",
	number = true,
	smartcase = true,
	splitbelow = true,
	splitright = true,
	tabstop = 4,
	undofile = true,
    colorcolumn = "80",
    hlsearch = false,
    incsearch = true,
    relativenumber = false,
    scrolloff = 6,
    shiftwidth = 4,
    signcolumn = "yes:1",
    smartindent = true,
    ignorecase = true,
    softtabstop = 4,
    swapfile = false,
    undodir = os.getenv("HOME") .. "/.vim/undodir",
    updatetime = 50,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.g.mapleader = " "

vim.cmd([[highlight clear SignColumn]])
