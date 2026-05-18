-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")
local colors = require("catppuccin-mocha")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Home config
hl.monitor({
    output = "desc:LG Electronics LG HDR 4K 0x00048B3D",
    mode = "3840x2160@60",
    position = "0x0",
    scale = 1.5,
})
-- Laptop
local default_laptop = {
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = 1.33,
}
hl.monitor(default_laptop)
-- Work screens
hl.monitor({
    output = "desc:LG Electronics LG ULTRAGEAR 508BNPS1H816",
    mode = "preferred",
    position = "auto-up",
    scale = 1,
})
-- All other screens
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto-right",
    scale    = "auto",
})


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl setcursor oreo_purple_cursors 32")
    hl.exec_cmd("app2unit -- fcitx5 -kr")
    hl.exec_cmd("QT_QPA_PLATFORM=xcb app2unit -- /usr/bin/kdeconnectd")
    hl.exec_cmd("app2unit -- kdeconnect-indicator")
    hl.exec_cmd("app2unit -- playerctld daemon")
    hl.exec_cmd("app2unit -u sunsetctl.service -t service -s b -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh")
    hl.exec_cmd("app2unit -- bat-notif")
    hl.exec_cmd("app2unit -u awww-daemon.service -t service -s b -- awww-daemon")
    hl.exec_cmd("app2unit -- awww-randomize")
    hl.exec_cmd("app2unit -- walker --gapplication-service")
end)

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})


hl.permission({ binary = "/usr/bin/hyprlock", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/hyprpicker", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/lib/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/home/martin/.config/hypr/screenshot", type = "screencopy", mode = "allow" })

hl.permission({ binary = "/usr/bin/hyprpm", type = "plugin", mode = "allow" })

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in           = 5,
        gaps_out          = 10,

        border_size       = 2,
        no_focus_fallback = true,

        col               = {
            active_border   = { colors = { colors.mauve, colors.blue, colors.pink }, angle = 90 },
            inactive_border = colors.surface0
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border  = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing     = false,

        layout            = "scrolling",

        snap              = {
            enabled = true,
            border_overlap = true,
            respect_gaps = true,
        },
    },

    decoration = {
        rounding = 5,

        shadow   = {
            enabled      = true,
            range        = 4,
            render_power = 1,
        },

        blur     = {
            enabled           = true,
            size              = 16,
            passes            = 4,
            contrast          = 1.5,
            vibrancy          = 1,
            vibrancy_darkness = 1,
            brightness        = 1,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        focus_fit_method = 1,
        explicit_column_widths = "0.25, 0.333, 0.5, 0.667, 0.75, 1",
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
        force_default_wallpaper = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        enable_swallow = true,
        swallow_regex = "^(com.mitchellh.ghostty)$",
        allow_session_lock_restore = true,
        font_family = "JetBrainsMono Nerd Font Mono",
        screencopy_force_8b = true,
    },
    xwayland = {
        force_zero_scaling = true,
        create_abstract_socket = true,
    },
    render = {
        direct_scanout = 2, -- 0 - off, 1 - on, 2 - auto (on with content type ‘game’)
        ctm_animation = 1,  -- ctm == hyprsunset
        cm_auto_hdr = 2,    -- Auto-switch to HDR in fullscreen when needed. 0 - off, 1 - switch to cm, hdr, 2 - switch to cm, hdredid
        new_render_scheduling = true,
    },
    debug = {
        disable_logs = false,
    },
    ecosystem = {
        no_donation_nag = true,
    }
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout                   = "us",
        kb_variant                  = "",
        kb_model                    = "",
        kb_options                  = "compose:ralt",
        kb_rules                    = "",

        follow_mouse                = 2,
        accel_profile               = "flat",
        float_switch_override_focus = 2,
        mouse_refocus               = false,

        scroll_factor               = 1.1,
        sensitivity                 = 0,
        emulate_discrete_scroll     = 0,

        touchpad                    = {
            natural_scroll = true,
        },
    },
    cursor = {
        no_hardware_cursors = 2,
        no_warps = true,
        hide_on_key_press = true,
        hide_on_touch = true,
        use_cpu_buffer = true,
        zoom_rigid = true,
        zoom_detached_camera = false,
    },
    gestures = {
        workspace_swipe_distance = 200,
        workspace_swipe_cancel_ratio = 0,
        workspace_swipe_min_speed_to_force = 0,
        workspace_swipe_direction_lock = false,
        workspace_swipe_direction_lock_threshold = 1000,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "scroll_move" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name          = "pixa3854:00-093a:0274-touchpad",
    accel_profile = "adaptive",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Movement
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + ALT + h", hl.dsp.focus({ monitor = "1" }))
hl.bind("ALT + TAB", hl.dsp.focus({ last = true }))

-- Window behavior
hl.bind(mainMod .. " + SHIFT + f", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + m", hl.dsp.layout("fit active"))
hl.bind(mainMod .. " + v", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + i", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + u", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + p", hl.dsp.window.pseudo())

-- Moving windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- Changing split ratio
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

-- Moving workspaces
hl.bind(mainMod .. " + CTRL + ALT + l", hl.dsp.workspace.move({ workspace = "+0", monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + ALT + h", hl.dsp.workspace.move({ workspace = "+0", monitor = "1" }))

-- Workspace switching / moving windows
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- System controls
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

-- Hyprland Management
local function reload()
    hl.exec_cmd("hyprctl reload")
    hl.exec_cmd("systemctl restart --user waybar")
    hl.exec_cmd("systemctl stop --user sunsetctl.service")
    hl.exec_cmd(
        "setsid -f app2unit -u sunsetctl.service -t service -s b -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh")
    hl.exec_cmd("systemctl stop --user awww-daemon.service")
    hl.exec_cmd("setsid -f app2unit -u awww-daemon.service -t service -s b -- awww-daemon")
end

hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + q", hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + r", reload)
hl.bind(mainMod .. " + SHIFT + w", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + s", hl.dsp.window.toggle_swallow())

-- App start shortcuts
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty +new-window"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("pkill hyprpicker || app2unit -- hyprpicker -a"))
hl.bind("Print", hl.dsp.exec_cmd("app2unit -- ~/.config/hypr/screenshot"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("app2unit -- ~/.config/hypr/screenshot --freeze"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.global("com.mitchellh.ghostty:SHIFT+LOGO+Return"))

-- Runner
hl.bind(mainMod .. " + r", hl.dsp.exec_cmd("nc -U /run/user/1000/walker/walker.sock"))
hl.bind(mainMod .. " + ALT + w", hl.dsp.exec_cmd("walker-kill"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("elephant menu system-control"))

-- Open popups
hl.bind(mainMod .. " + o", hl.dsp.submap("open"))
hl.define_submap("open", function()
    hl.bind("a", hl.dsp.exec_cmd("ghostty +new-window --title='-float-' -e /usr/bin/wiremix"))
    hl.bind("b", hl.dsp.exec_cmd("ghostty +new-window --title='-float-' -e /usr/bin/bluetui"))
    hl.bind("w", hl.dsp.exec_cmd("ghostty +new-window --title='-float-' -e /usr/bin/impala"))
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- Notification Submap
hl.bind(mainMod .. " + n", hl.dsp.submap("notif"))
hl.define_submap("notif", function()
    hl.bind("c", hl.dsp.exec_cmd("dunstctl close-all"))
    hl.bind("p", hl.dsp.exec_cmd("dunstctl set-paused toggle"))
    hl.bind("x", hl.dsp.exec_cmd("dunstctl history-clear"))
    hl.bind("a", hl.dsp.exec_cmd("dunstctl action 0"))
    for i = 1, 10 do
        local key = i % 10
        hl.bind(tostring(key), hl.dsp.exec_cmd("dunstctl action " .. (i - 1)))
    end
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lid switch
local function lid_closed()
    local monitors = hl.get_monitors()
    if #monitors ~= 1 then
        hl.monitor({
            output = "eDP-1",
            disabled = true,
        })
        hl.exec_cmd("systemctl --user restart waybar.service")
    end
end

local function lid_open()
    hl.monitor(default_laptop)
    hl.exec_cmd("systemctl --user restart waybar.service")
end

hl.bind("switch:on:Lid Switch", lid_closed, { locked = true })
hl.bind("switch:off:Lid Switch", lid_open, { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    name = "slack-to-4",
    match = { class = "Slack" },
    workspace = "4 silent",
})

hl.window_rule({
    name = "spotify-to-10",
    match = { title = "^(Spotify Premium)$" },
    workspace = "10 silent",
})

hl.window_rule({
    name = "float-and-position-notifications",
    match = { class = "^()$" },
    float = true,
    move = { "(min(max((monitor_w*1),0),monitor_w-window_w))", "(min(max(-(monitor_h*1),0),monitor_h-window_h))" },
    no_initial_focus = true,
})

hl.window_rule({
    name = "proper-pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
})

hl.window_rule({
    name = "special-floating-title",
    match = { title = ".*\\-float\\-.*" },
    float = true,
    pin = true,
    stay_focused = true,
    dim_around = true,
})

hl.window_rule({
    name = "float-popups",
    match = { class = "^(hyprland-share-picker|xdg-desktop-portal-gtk)$" },
    float = true,
})

hl.window_rule({
    name = "allow-tearing-for-steam",
    match = { initial_class = "^(steam_app.*)$" },
    immediate = true,
})

hl.layer_rule({
    name = "disable-walker-animations",
    match = { namespace = "walker" },
    no_anim = true,
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "disable-screenshot-animations",
    match = { namespace = "selection" },
    no_anim = true,
})
