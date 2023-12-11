# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
import os
import subprocess

from libqtile import layout, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import extension


from screen import init_screens

mod = "mod4"
terminal = guess_terminal()
menu = "rofi -show drun -show-icons -theme github/dotfiles/dotfiles/.config/rofi/themes/catppuccin-frappe.rasi"


# A function for hide/show all windows in a group
@lazy.function
def minimize_all(qtile: qtile):
    # https://gitlab.com/dwt1/dotfiles/-/blob/master/.config/qtile/config.py?ref_type=heads
    for window in qtile.current_group.windows:
        if hasattr(window, "toggle_minimize"):
            window.toggle_minimize()


###############################################################################
################################# Keybindings #################################
###############################################################################

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    # Vim mode
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Alternative mode
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    # Vim mode
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        desc="Move window down"
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_up(),
        desc="Move window up"
    ),
    # Alternative mode
    Key(
        [mod, "shift"],
        "Left",
        lazy.layout.shuffle_left(),
        desc="Move window to the left",
    ),
    Key(
        [mod, "shift"],
        "Right",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key(
        [mod, "shift"],
        "Down",
        lazy.layout.shuffle_down(),
        desc="Move window down"
    ),
    Key(
        [mod, "shift"],
        "Up",
        lazy.layout.shuffle_up(),
        desc="Move window up"
    ),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    # Vim mode
    Key(
        [mod, "control"],
        "h",
        lazy.layout.grow_left(),
        desc="Grow window to the left"
    ),
    Key(
        [mod, "control"],
        "l",
        lazy.layout.grow_right(),
        desc="Grow window to the right"
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.grow_down(),
        desc="Grow window down"
    ),
    Key(
        [mod, "control"],
        "k",
        lazy.layout.grow_up(),
        desc="Grow window up"
    ),
    # Alternative mode
    Key(
        [mod, "control"],
        "Left",
        lazy.layout.grow_left(),
        desc="Grow window to the left",
    ),
    Key(
        [mod, "control"],
        "Right",
        lazy.layout.grow_right(),
        desc="Grow window to the right",
    ),
    Key(
        [mod, "control"],
        "Down",
        lazy.layout.grow_down(),
        desc="Grow window down"
    ),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    # Reset all window sizes, positions and layouts
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key(
        [mod],
        "m",
        lazy.layout.maximize(),
        desc="Toggle between min and max sizes"
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="toggle fullscreen"),
    Key(
        [mod, "shift"],
        "m",
        minimize_all(),
        desc="Toggle hide/show all windows on current group",
    ),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
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
    # Terminal
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Kill focused windo<SUBSTITUTE_$DOCKER_IMAGE_HERE>
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    # Reload Qtile
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    # Shutdown Qtile
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Spawn a command using a prompt widget
    Key(
        [mod],
        "r",
        lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"
    ),
    # Key([mod], 'r', lazy.run_extension(extension.DmenuRun(
    #     dmenu_prompt=">",
    #     dmenu_font="Andika-8",
    #     background="#15181a",
    #     foreground="#00ff00",
    #     selected_background="#079822",
    #     selected_foreground="#fff",
    #     dmenu_height=24,  # Only supported by some dmenu forks
    # ))),
    # Media keys
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("amixer sset Master 5%-"),
        desc="Lower Volume by 5%",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("amixer sset Master 5%+"),
        desc="Raise Volume by 5%",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("amixer sset Master 1+ toggle"),
        desc="Mute/Unmute Volume",
    ),
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn("playerctl play-pause"),
        desc="Play/Pause player",
    ),
    Key(
        [],
        "XF86AudioNext",
        lazy.spawn("playerctl next"),
        desc="Skip to next"
    ),
    Key(
        [],
        "XF86AudioPrev",
        lazy.spawn("playerctl previous"),
        desc="Skip to previous"
    ),
    # Rofi / Wofi
    Key([mod], "d", lazy.spawn(
        menu),
        desc="Launch rofi menu"
        )
]

groups = [Group(i) for i in "123456789"]

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
            # mod1 + shift + letter of group =
            # switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}"\
                    .format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )


# Dracula  = [
#     ["#282a36", "#282a36"], # bg
#     ["#f8f8f2", "#f8f8f2"], # fg
#     ["#000000", "#000000"], # color01
#     ["#ff5555", "#ff5555"], # color02
#     ["#50fa7b", "#50fa7b"], # color03
#     ["#f1fa8c", "#f1fa8c"], # color04
#     ["#bd93f9", "#bd93f9"], # color05
#     ["#ff79c6", "#ff79c6"], # color06
#     ["#9aedfe", "#9aedfe"]  # color15
#     ]
# DoomOne = [
#     ["#282c34", "#282c34"], # bg
#     ["#bbc2cf", "#bbc2cf"], # fg
#     ["#1c1f24", "#1c1f24"], # color01
#     ["#ff6c6b", "#ff6c6b"], # color02
#     ["#98be65", "#98be65"], # color03
#     ["#da8548", "#da8548"], # color04
#     ["#51afef", "#51afef"], # color05
#     ["#c678dd", "#c678dd"], # color06
#     ["#46d9ff", "#46d9ff"]  # color15
#     ]

layout_theme = {
    "border_width": 4,
    "margin": 8,
    "border_focus": "#bd93f9",
    "border_normal": "#9aedfe",
}
layouts = [
    layout.Max(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Tile(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]



# class TooltipTextBox(TextBox, TooltipMixin):
#     def __init__(self, *args, **kwargs):
#         TextBox.__init__(self, *args, **kwargs)
#         TooltipMixin.__init__(self, **kwargs)
#         self.add_defaults(TooltipMixin.defaults)

#         # The tooltip text is set in the following variable
#         self.tooltip_text = "Tooltip message goes here..."

# bar = TooltipTextBox()

screens = init_screens()


# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod],
        "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the
        # wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="Lutris"),  # Lutris
        Match(title="steam"),  # Steam,
        Match(title="Authentication .*"),  # Authentication dialog,
        Match(title="League of Legends"),  # LOL,
        Match(title="volume control"),
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# I wrote the hook below auto minimize = True line in the default config file.
# This doesn't matter. But if you are new and confused, now you know :)


@hook.subscribe.startup_once
def autostart():
    processes = [
        ["picom", "-b", "--config", os.path.expanduser("~/.config/picom/picom.conf")],
        ["nm-applet", "--indicator"],
        ["/usr/lib/polkit-kde-authentication-agent-1"],
        ["blueman-applet"],
        [os.path.expanduser("~/.screenlayout/layout.sh")],
        ["dunst"],
        ["volumeicon"],
    ]
    for p in processes:
        subprocess.Popen(p)


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
