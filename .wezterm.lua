local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local function read_decoration_state()
  local state_path = os.getenv('APPDATA') .. '\\wezterm\\decorations_state.txt'
  local file = io.open(state_path, 'r')
  if not file then
    return 'TITLE|RESIZE'
  end

  local content = file:read('*l')
  file:close()

  if content == 'NONE' then
    return 'NONE'
  end

  return 'TITLE|RESIZE'
end

local function write_decoration_state(state)
  local dir = os.getenv('APPDATA') .. '\\wezterm'
  os.execute('mkdir "' .. dir .. '" 2>nul')

  local file = io.open(dir .. '\\decorations_state.txt', 'w')
  if file then
    file:write(state)
    file:close()
  end
end

-- Example settings
config.initial_cols = 120
config.initial_rows = 28
config.font = wezterm.font_with_fallback({
  { family = 'Cascadia Mono', weight = 'Regular' },
  { family = 'Cascadia Code', weight = 'Medium' },
  { family = 'Consolas' },
  { family = 'Segoe UI Emoji' },
})
config.font_size = 10.0
config.line_height = 1.05
config.color_scheme = 'Campbell'
config.launch_menu = {}
config.window_decorations = read_decoration_state()
config.default_prog = {
  'powershell.exe',
  '-NoLogo',
  '-NoExit',
  '-Command',
  '& { $global:ShowPromptPath = $false; function prompt { if ($global:ShowPromptPath) { "$PWD> " } else { "> " } } }',
}

config.keys = {
  {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(_, pane)
      pane:send_text([[
$global:ShowPromptPath = -not $global:ShowPromptPath
if ($global:ShowPromptPath) {
  function prompt { "$PWD> " }
} else {
  function prompt { "> " }
}
]], false)
    end),
  },
  {
    key = 'h',
    mods = 'CTRL|ALT',
    action = wezterm.action_callback(function(window, pane)
      local current = read_decoration_state()
      local next_state = (current == 'NONE') and 'TITLE|RESIZE' or 'NONE'
      write_decoration_state(next_state)
      config.window_decorations = next_state
      window:perform_action(wezterm.action.ReloadConfiguration(), pane)
    end),
  },
}

-- Make the window background, title area, and tab bar appear softly translucent and minimal
config.window_background_opacity = 0.0
config.text_background_opacity = 0.0
config.use_fancy_tab_bar = false
config.window_frame = {
  active_titlebar_bg = '#fefeff',
  inactive_titlebar_bg = '#f5f6fa',
  font = wezterm.font({ family = 'Segoe UI' }),
  font_size = 8.0,
}
config.colors = {
  foreground = '#f8fafc',
  background = '#0f172a',
  cursor_bg = '#f8fafc',
  cursor_fg = '#0f172a',
  cursor_border = '#f8fafc',
  selection_bg = '#334155',
  selection_fg = '#f8fafc',
  ansi = {
    '#0f172a', '#ef4444', '#22c55e', '#f59e0b', '#3b82f6', '#a855f7', '#06b6d4', '#e2e8f0',
  },
  brights = {
    '#64748b', '#f87171', '#4ade80', '#fde68a', '#60a5fa', '#c084fc', '#67e8f9', '#ffffff',
  },
  tab_bar = {
    background = '#111827',
    active_tab = {
      bg_color = '#1e293b',
      fg_color = '#f8fafc',
    },
    inactive_tab = {
      bg_color = '#0f172a',
      fg_color = '#94a3b8',
    },
    inactive_tab_hover = {
      bg_color = '#1e293b',
      fg_color = '#f8fafc',
    },
    new_tab = {
      bg_color = '#0f172a',
      fg_color = '#94a3b8',
    },
    new_tab_hover = {
      bg_color = '#1e293b',
      fg_color = '#f8fafc',
    },
  },
}
config.window_padding = {
  left = 8,
  right = 8,
  top = 3,
  bottom = 3,
}

return config
