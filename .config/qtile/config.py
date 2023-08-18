import subprocess

from libqtile import bar, hook, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"
terminal = "kitty"


class Theme:
    wallpaper = "~/.local/share/backgrounds/planets.jpg"
    background = "#282a36"
    secondary = "#44475a"
    alternate = "#6272a4"
    foreground = "#f8f8f2"
    purple = "#bd93f9"
    pink = "#ff79c6"
    red = "#ff5555"
    green = "#50fa7b"
    cyan = "#8be9fd"
    orange = "#ffb86c"
    yellow = "#f1fa8c"


bemenu = """
            bemenu-run \
                --fn 'JetBrainsMono Nerd Font 32'\
                --tb '#6272a4'\
                --tf '#f8f8f2'\
                --fb '#282a36'\
                --ff '#f8f8f2'\
                --nb '#282a36'\
                --nf '#6272a4'\
                --hb '#44475a'\
                --hf '#50fa7b'\
                --sb '#44475a'\
                --sf '#50fa7b'\
                --scb '#282a36'\
                --scf '#ff79c6'\
                --bdr '#bd93f9'\
                -l 10\
                -c\
                -W 0.25\
                -p 'run'\
                -i\
                -B 4
        """


@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(["betterlockscreen", "-u", Theme.wallpaper])
    subprocess.Popen(["autorandr", "-c"])


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        desc="Move window to the left",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn(bemenu), desc="Launch bemenu"),
    # System Controls
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.spawn("xbacklight +5"),
        desc="Increase brightness",
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.spawn("xbacklight -5"),
        desc="Decrease brightness",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("amixer -D 'default' set 'Master' playback 5%+"),
        desc="Increase volume",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("amixer -D 'default' set 'Master' playback 5%-"),
        desc="Decrease volume",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("amixer -D 'default' set 'Master' toggle"),
        desc="Mute volume",
    ),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Take screenshot"),
    # Lockscreen
    Key(
        [mod, "shift"],
        "w",
        lazy.spawn("betterlockscreen -l dimblur"),
        desc="Lock screen",
    ),
    # Window modification
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle window fullscreen"),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle window float"),
    Key([mod], "u", lazy.next_urgent(), desc="To urgent window"),
]

groups = [Group(i) for i in "1234567890"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name),
                desc="Move focused window to group {}".format(i.name),
            ),
        ]
    )

layouts = [
    layout.Columns(  # type: ignore
        border_focus=Theme.purple,
        border_focus_stack=Theme.purple,
        border_normal=Theme.secondary,
        border_normal_stack=Theme.secondary,
        border_on_single=True,
        border_width=4,
        insert_position=1,
        margin=8,
    ),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=24,
    padding=12,
    background=None,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(padding=3),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Systray(),
                widget.Volume(),
                widget.Backlight(
                    backlight_name="intel_backlight",
                ),
                widget.Battery(
                    notify_below=10,
                ),
                widget.Clock(format="%Y-%m-%d %a %H:%M"),
            ],
            48,
            background=Theme.alternate,
            border_width=4,
            border_color=Theme.secondary,
            margin=[8, 8, 0, 8],
            opacity=0.5,
        ),
        wallpaper=Theme.wallpaper,
        wallpaper_mode="fill",
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(  # type: ignore
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,  # type: ignore
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "urgent"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
