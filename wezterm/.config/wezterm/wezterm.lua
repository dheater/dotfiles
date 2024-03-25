-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Dracula'

config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true

-- alias
local act = wezterm.action

-- Open the command palette
config.keys = {
  {
    key = 'P',
    mods = 'CTRL',
    action = act.ActivateCommandPalette,
  },
}

-- Open the tabs list
config.keys = {
  {
    key = 'T',
    mods = 'CTRL',
    action = act.ShowTabNavigator,
  },
  -- other keys
}

-- and finally, return the configuration to wezterm
return config
