function ColorOpts(color)
	color = color or "adwaita"
	vim.cmd.colorscheme(color)
end

ColorOpts()
