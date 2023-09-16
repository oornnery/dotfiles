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

from email.policy import default
import os
import subprocess
from libqtile import bar, extension, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
# Make sure 'qtile-extras' is installed or this config will not work.
from qtile_extras.widget.decorations import BorderDecoration
from qtile_extras.resources import wallpapers

#from qtile_extras.widget import StatusNotifier
import colors



mod = "mod4"
myTerm = "alacritty"      # My terminal of choice
terminal = guess_terminal()


# A function for hide/show all windows in a group
@lazy.function
def minimize_all(qtile):
    # https://gitlab.com/dwt1/dotfiles/-/blob/master/.config/qtile/config.py?ref_type=heads
    for window in qtile.current_group.windows:
        if hasattr(window, "toggle_minimize"):
            window.toggle_minimize()


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
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Alternative mode
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    
    
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    # Vim mode
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    # Alternative mode
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    
    # Reset all window sizes, positions and layouts
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod, "shift"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    
    # Terminal
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Kill focused window
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    # Reload Qtile
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    # Shutdown Qtile
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Spawn a command using a prompt widget
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    
    # Media keys
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master 5%-"), desc="Lower Volume by 5%"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master 5%+"), desc="Raise Volume by 5%"),
    Key([], "XF86AudioMute", lazy.spawn("amixer sset Master 1+ toggle"), desc="Mute/Unmute Volume"),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause player"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Skip to next"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Skip to previous"),

    # Rofi scripts
    Key([mod], "d", lazy.spawn("rofi -modi drun -show drun -config ~/.config/rofi/rofidmenu.rasi")),
]

# groups = [Group(i) for i in "123456789"]

groups = []
group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9",]

#group_labels = ["DEV", "WWW", "SYS", "DOC", "VBOX", "CHAT", "MUS", "VID", "GFX",]
group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9",]
#group_labels = ["", "", "", "", "", "", "", "", "",]

group_layouts = ["max", "max", "tile", "", "", "", "", "", ""]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))



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
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

### COLORSCHEME ###
# Colors are defined in a separate 'colors.py' file.
# There 10 colorschemes available to choose from:
#
# colors = colors.DoomOne
# colors = colors.Dracula
# colors = colors.GruvboxDark
# colors = colors.MonokaiPro
# colors = colors.Nord
# colors = colors.OceanicNext
# colors = colors.Palenight
# colors = colors.SolarizedDark
# colors = colors.SolarizedLight
# colors = colors.TomorrowNight
#
# It is best not manually change the colorscheme; instead run 'dtos-colorscheme'
# which is set to 'MOD + p c'

colors = colors.Nord

### LAYOUTS ###
# Some settings that I use on almost every layout, which saves us
# from having to type these out for each individual layout.
layout_theme = {"border_width": 2,
                "margin": 4,
                "border_focus": colors[8],
                "border_normal": colors[0]
                }


layouts = [
    layout.Max(
        border_width=0,
        margin=0
        ),
    layout.MonadTall(**layout_theme),
    layout.Tile(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(**layout_theme, num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
     layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


def separator():
    return widget.TextBox(
        text = '|',
        font = "Ubuntu Mono",
        foreground = colors[1],
        padding = 2,
        fontsize = 14
        )

screens = [
    Screen(
        # This is the path including the file name for your wallpaper. And also set wallpaper_mode.
        wallpaper="~/.wallpapers/archlinux_1.jpg",
        wallpaper_mode="fill",
        top=bar.Bar(
            [
                widget.Image(
                    filename="~/.config/qtile/icons/logo_linux.png",
                    scale="False",
                    mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(myTerm)},
                ),
                widget.CurrentLayoutIcon(
                        # custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
                        foreground = colors[1],
                        padding = 0,
                        scale = 0.7
                        ),
                widget.CurrentLayout(
                        foreground = colors[1],
                        padding = 5
                        ),
                separator(),
                widget.Prompt(
                        font = "Ubuntu Mono",
                        fontsize=14,
                        foreground = colors[1]
                ),
                widget.GroupBox(
                        fontsize = 11,
                        margin_y = 3,
                        margin_x = 4,
                        padding_y = 2,
                        padding_x = 3,
                        borderwidth = 3,
                        active = colors[8],
                        inactive = colors[1],
                        rounded = False,
                        highlight_color = colors[2],
                        highlight_method = "line",
                        this_current_screen_border = colors[7],
                        this_screen_border = colors [4],
                        other_current_screen_border = colors[7],
                        other_screen_border = colors[4],
                        ),
                separator(),
                widget.WindowName(
                        foreground = colors[6],
                        max_chars = 40
                        ),
                widget.GenPollText(
                    update_interval = 300,
                    func = lambda: subprocess.check_output("printf $(uname -r)", shell=True, text=True),
                    foreground = colors[3],
                    fmt = '❤  {}',
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e neofetch && read -p "Enter your name: " username && echo "Hello, $username!"')},
                    decorations=[
                        BorderDecoration(
                            colour = colors[3],
                            border_width = [0, 0, 2, 0],
                        )
                    ],
                    ),
                widget.Spacer(length = 8),
                widget.CPU(
                        format = '▓  Cpu: {load_percent}%',
                        foreground = colors[4],
                        decorations=[
                            BorderDecoration(
                                colour = colors[4],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.Memory(
                        foreground = colors[8],
                        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e htop')},
                        format = '{MemUsed: .0f}{mm}',
                        fmt = '🖥  Mem: {} used',
                        decorations=[
                            BorderDecoration(
                                colour = colors[8],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.DF(
                        update_interval = 60,
                        foreground = colors[5],
                        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e df')},
                        partition = '/',
                        #format = '[{p}] {uf}{m} ({r:.0f}%)',
                        format = '{uf}{m} free',
                        fmt = '🖴  Disk: {}',
                        visible_on_warn = False,
                        decorations=[
                            BorderDecoration(
                                colour = colors[5],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.Volume(
                        foreground = colors[7],
                        fmt = '🕫  Vol: {}',
                        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myTerm + ' -e pavucontrol')},
                        decorations=[
                            BorderDecoration(
                                colour = colors[7],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.KeyboardLayout(
                        foreground = colors[4],
                        fmt = '⌨  Kbd: {}',
                        configured_keyboards=['br','us'],
                        decorations=[
                            BorderDecoration(
                                colour = colors[4],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.Clock(
                        foreground = colors[8],
                        format = "⏱  %a, %b %d - %H:%M",
                        decorations=[
                            BorderDecoration(
                                colour = colors[8],
                                border_width = [0, 0, 2, 0],
                            )
                        ],
                        ),
                widget.Spacer(length = 8),
                widget.Systray(padding = 3),
                widget.Spacer(length = 8),

                        widget.QuickExit(
                            **widget_defaults,
                            default_text=" "
                            ),
                    ],
                    24,
                    # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
                    # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
                ),
            ),
        ]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=colors[8],
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry,
        Match(title="Lutris"),  # Lutris
        Match(title="steam"),  # Steam,
        Match(title="League of Legends"),  # LOL,
        Match(title="volume control")
        
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
@hook.subscribe.startup
def autostart():
    home = os.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
