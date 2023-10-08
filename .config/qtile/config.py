# pylint: disable=missing-docstring,invalid-name,too-few-public-methods, global-statement
import os
import random
import subprocess

from libqtile import bar, hook, qtile
from libqtile.backend import base
from libqtile.config import Drag, Group, Key, Match, Screen
from libqtile.core.manager import Qtile
from libqtile.layout.columns import Columns
from libqtile.layout.floating import Floating
from libqtile.lazy import lazy
from qtile_extras import widget

qtile: Qtile
terminal = "kitty"


def get_wallpaper():
    folder = os.path.expanduser("~/.local/share/backgrounds")
    files = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    return "~/.local/share/backgrounds/" + random.choice(files) if files else ""


class Theme:
    wallpaper = get_wallpaper()
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
    transparent = "#00000000"


bemenu = """
            bemenu-run \
                --fn 'JetBrainsMono Nerd Font Mono 32'\
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


def make_icon(raw_unicode: str) -> str:
    return raw_unicode.encode("utf-16", "surrogatepass").decode("utf-16")


def send_notif(_, title: str, body: str = ""):
    subprocess.Popen(["notify-send", title, body])


@hook.subscribe.startup_complete
def autostart():
    subprocess.Popen(["/usr/lib/kdeconnectd"])
    subprocess.Popen("playerctld daemon", shell=True)
    subprocess.Popen(["picom", "-b"])
    subprocess.run("autorandr -c", shell=True)
    subprocess.Popen(f"betterlockscreen -u {get_wallpaper()}", shell=True)


@hook.subscribe.focus_change
def color_tasklist():
    window_count = len(qtile.current_screen.group.windows)
    tasklist = qtile.current_screen.top.widgets[2]
    if window_count == 0:
        tasklist.decorations[0].colour = Theme.transparent
    if window_count == 1:
        tasklist.decorations[0].colour = Theme.purple
    if window_count > 1:
        tasklist.decorations[0].colour = Theme.alternate


mod = "mod4"
alt = "mod1"

focus_keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "tab", lazy.layout.previous(), desc="Move focus to previous window"),
    Key([mod], "u", lazy.next_urgent(), desc="To urgent window"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, alt], "h", lazy.prev_screen(), desc="Move focus to previous screen"),
    Key([mod, alt], "l", lazy.next_screen(), desc="Move focus to next screen"),
]

layout_keys = [
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
    # Window modification
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle window fullscreen"),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle window float"),
    Key([mod], "m", lazy.window.toggle_maximize(), desc="Toggle window fullscreen"),
    Key([mod, "shift"], "m", lazy.window.toggle_minimize(), desc="Toggle window float"),
]

system_keys = [
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
        lazy.spawn("amixer -D default set Master 5%+"),
        desc="Increase volume",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("amixer -D default set Master 5%-"),
        desc="Decrease volume",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("amixer -D default set Master toggle"),
        desc="Mute volume",
    ),
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn("playerctl play-pause"),
        desc="Toggle audio",
    ),
    Key(
        [],
        "XF86AudioPrev",
        lazy.spawn("playerctl previous"),
        desc="Toggle audio",
    ),
    Key(
        [],
        "XF86AudioNext",
        lazy.spawn("playerctl next"),
        desc="Toggle audio",
    ),
]

action_keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn(bemenu), desc="Launch bemenu"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Take screenshot"),
    # Lockscreen
    Key(
        [mod, "shift"],
        "w",
        lazy.spawn("betterlockscreen -l dimblur"),
        desc="Lock screen",
    ),
]

keys = [*focus_keys, *layout_keys, *system_keys, *action_keys]

groups = [Group(i) for i in "1234567890"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod1 + shift + letter of group = move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name),
                desc=f"Move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    Columns(
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
    font="JetBrainsMono Nerd Font Mono Light",
    fontsize=24,
    padding=12,
    background=Theme.transparent,
    foreground=Theme.foreground,
    # theme_path="~/.icons/dracula-icons/24",
)
extension_defaults = widget_defaults.copy()

BARS_COUNT = 0


def make_bar():
    global BARS_COUNT
    BARS_COUNT += 1

    decoration_group = {
        "decorations": [
            widget.decorations.RectDecoration(
                colour=[Theme.alternate], radius=23, filled=True, group=True
            )
        ],
    }

    b = bar.Bar(
        [
            widget.GroupBox(
                highlight_method="block",
                this_current_screen_border=Theme.purple,
                this_screen_border=Theme.secondary,
                other_current_screen_border=Theme.background,
                other_screen_border=Theme.background,
                spacing=3,
                padding=3,
                margin_x=12,
                disable_drag=True,
                **decoration_group,
            ),
            widget.Spacer(length=300),
            widget.TaskList(
                border=Theme.purple,
                highlight_method="block",
                margin_x=24,
                margin_y=3,
                padding=9,
                unfocused_border=Theme.alternate,
                urgent_border=Theme.red,
                txt_minimized=make_icon("\udb81\uddb0") + " ",
                txt_floating=make_icon("\udb84\udcac") + " ",
                txt_maximized=make_icon("\udb81\uddaf") + " ",
                icon_size=24,
                title_width_method="uniform",
                decorations=[
                    widget.decorations.RectDecoration(
                        colour=Theme.transparent, radius=23, filled=True, group=True
                    )
                ],
            ),
            widget.Spacer(length=300),
            widget.StatusNotifier(**decoration_group),
            widget.Spacer(length=15),
            widget.Volume(
                volume_app="pavucontrol",
                fmt=make_icon("\udb81\udd7e") + " {}",
                **decoration_group,
            ),
            widget.Backlight(
                fmt=make_icon("\udb80\udcde") + " {}",
                backlight_name="intel_backlight",
                **decoration_group,
            ),
            widget.Spacer(length=15),
            widget.Battery(
                notify_below=10,
                charge_char=make_icon("\udb80\udc84"),
                discharge_char=make_icon("\udb80\udc7e"),
                empty_char=make_icon("\udb80\udc83"),
                full_char=make_icon("\udb80\udc79"),
                unknown_char=make_icon("\udb80\udc91"),
                format="{char} {percent:2.0%} {hour:d}:{min:02d}",
                **decoration_group,
            ),
            widget.ThermalSensor(
                fmt=make_icon("\uf4bc") + " {}",
                threshold=90,
                foreground_alert=Theme.red,
                **decoration_group,
            ),
            widget.Spacer(length=15),
            widget.Clock(format="%a %d %b %H:%M:%S", **decoration_group),
        ],
        48,
        background=Theme.transparent,
        border_width=0,
        border_color=Theme.transparent,
        margin=[8, 8, 0, 8],
        opacity=1,
    )
    return b


screens = [
    Screen(
        top=make_bar(),
        wallpaper=Theme.wallpaper,
        wallpaper_mode="fill",
    ),
    Screen(
        top=make_bar(),
        wallpaper=Theme.wallpaper,
        wallpaper_mode="fill",
    ),
    Screen(
        top=make_bar(),
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
bring_front_click = True
cursor_warp = False
floating_layout = Floating(
    border_focus=Theme.pink,
    border_normal=Theme.secondary,
    border_width=4,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="zoom"),  # zoom
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
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
