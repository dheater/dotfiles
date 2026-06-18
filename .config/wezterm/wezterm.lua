-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Dracula'
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
-- config.disable_default_key_bindings = true

-- alias
local act = wezterm.action

-- timeout_milliseconds defaults to 1000 and can be omitted
-- Leader is the same as my old tmux prefix
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- splitting
  {
    mods   = "LEADER",
    key    = "-",
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
  },
  {
    mods   = "LEADER",
    key    = "|",
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
  },
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  },
  {
    mods = 'LEADER',
    key = 'z',
    action = wezterm.action.TogglePaneZoomState
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    mods = 'LEADER',
    key = 'Space',
    action = wezterm.action.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = 't',
    mods = 'LEADER',
    action = act.ShowTabNavigator,
  },
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnCommandInNewTab {
      cwd = os.getenv('WEZTERM_CONFIG_DIR'),
      set_environment_variables = {
        TERM = 'screen-256color',
      },
      args = {
        'hx',
        os.getenv('WEZTERM_CONFIG_FILE'),
      },
    },
  },
  {
    key = 'LeftArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'r',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = 'C',
    mods = 'CTRL',
    action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
  },
  -- paste from the clipboard
  {
    key = 'V',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard'
  },
  -- paste from the primary selection
  {
    key = 'V',
    mods = 'CTRL',
    action = act.PasteFrom 'PrimarySelection'
  },
}

-- and finally, return the configuration to wezterm
return config
