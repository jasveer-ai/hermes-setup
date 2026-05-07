local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- ── General ──────────────────────────────────
config.default_prog = { "/bin/zsh", "-l" }
config.check_for_updates = false

-- ── Font ─────────────────────────────────────
config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font Mono",
    "JetBrainsMono Nerd Font",
    "JetBrains Mono",
})
config.font_size = 14
config.line_height = 1.2

-- ── Window ───────────────────────────────────
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10
config.window_decorations = "RESIZE"
config.window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 6,
}

-- ── Tabs ─────────────────────────────────────
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_max_width = 24

-- ── Scrollback ───────────────────────────────
config.scrollback_lines = 10000

-- ── Cursor ───────────────────────────────────
config.default_cursor_style = "SteadyBar"
config.cursor_thickness = 1.5

-- ── Color Scheme (Catppuccin Mocha) ──────────
config.color_scheme = "Catppuccin Mocha"

-- ── Keybindings ──────────────────────────────
config.keys = {
    { key = "n", mods = "SUPER", action = act.SpawnWindow },
    { key = "w", mods = "SUPER", action = act.CloseCurrentTab { confirm = true } },
    { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "LeftArrow", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackAndViewport") },
    { key = "f", mods = "SUPER", action = act.ToggleFullScreen },
}

return config
