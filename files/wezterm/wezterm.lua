local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 14.0
config.font = wezterm.font("Inconsolata Nerd Font", { weight = "Bold" })
config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }
config.window_background_opacity = 0.95

config.enable_tab_bar = false

config.default_cursor_style = "BlinkingBar"
config.audible_bell = "Disabled"
config.scrollback_lines = 5000

return config
