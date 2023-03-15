local opt = vim.opt

opt.relativenumber = false
opt.number = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = false

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.colorcolumn = "80"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("_")

opt.undofile = true

opt.hlsearch = true
opt.incsearch = true

opt.scrolloff = 6
opt.swapfile = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.updatetime = 50

