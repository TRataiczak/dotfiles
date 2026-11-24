-- ~/.config/hypr/hyprland.lua
local terminal = "kitty"
local menu     = "fuzzel"
local mod      = "SUPER"

------------------ MONITORS ------------------
-- Check names with `hyprctl monitors` and swap these if needed
local portrait = "DP-3"  -- left screen, rotated
local main     = "DP-2"  -- landscape, in front

-- Portrait is 1440 wide once rotated, so the main screen starts at x = 1440
-- If the portrait screen is upside down, change transform 1 to 3
hl.monitor({ output = portrait, mode = "preferred", position = "0x0",    scale = 1, transform = 1 })
hl.monitor({ output = main,     mode = "preferred", position = "1440x560", scale = 1 })

------------------ WORKSPACES ----------------
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = main, default = (i == 1) })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = portrait, default = (i == 6),
        layout = "scrolling", layout_opts = { direction = "down" } })
end

hl.config({ scrolling = { column_width = 0.333 } })

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
------------------ ENVIRONMENT ---------------
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")

------------------ AUTOSTART -----------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)

------------------ LOOK & FEEL ---------------
hl.config({
    general = {
        gaps_in = 4, gaps_out = 8, border_size = 2,
        col = {
            active_border   = "rgb(cdd6f4)",
            inactive_border = "rgb(1e1e2e)",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 6,
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = { disable_hyprland_logo = true, disable_splash_rendering = true, force_default_wallpaper = 0 },
    input = { kb_layout = "us", follow_mouse = 1, sensitivity = 0 },
})

------------------ KEYBINDS ------------------
-- Apps
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + L",      hl.dsp.exec_cmd("hyprlock"))

-- Windows
hl.bind(mod .. " + Q", hl.dsp.window.close())   -- graceful close
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())  -- check with configerrors
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + M", hl.dsp.layout("addmaster"))

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Focus and move: Super+arrows focus, Super+Shift+arrows move (works across monitors)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,             hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,     hl.dsp.window.move({ direction = dir }))
end
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))

-- Workspaces: 1-5 main screen, 6-0 portrait screen
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse move/resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
