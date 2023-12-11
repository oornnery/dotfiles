import os
from libqtile.config import Screen
from libqtile import bar, widget, qtile

from qtile_extras.widget.decorations import RectDecoration
from qtile_extras import widget as extra_widgets


menu = os.path.expanduser("~/.config/scripts/wofi_menu.sh")

decoration_group = {
    "decorations": [
        RectDecoration(
            colour="#282c34",
            radius=4,
            filled=True,
            group=True,
        )
    ],
    "font": "ttf-hack-nerd",
    "padding": 6,
    "margin_y": 3,
    "margin_x": 3,
    "fontsize": 14,
}


def settings_screen():
    return dict(
        30,
        border_width=[6, 6, 6, 6],  # Draw top and bottom borders
        background="#00000000",
        opacity=1,
        # Borders are magenta
        border_color=["00000000", "00000000", "00000000", "00000000"]
    )


def main_bar():
    return [
        extra_widgets.TextBox(
            '󰣇',
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(menu)},
            **decoration_group,
        ),
        extra_widgets.CurrentLayout(
            padding_y=6,
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.GroupBox(
            padding_y=6,
            highlight_method='block',
            **decoration_group
        ),
        widget.Prompt(),
        widget.Spacer(4),
        extra_widgets.WindowName(
            format="  {name}",
            max_chars=30,
            **decoration_group
        ),
        # Left
        widget.Spacer(4),
        extra_widgets.Net(
            fmt="  {}",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Bluetooth(
            format="󰂯  {name}({battery_level}%)",
            **decoration_group
        ),
        widget.Spacer(4),
        # Battery
        extra_widgets.Battery(
            format="  {percent:2.0%} ({hour:d}:{min:02d}) {watt:.2f}W",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.CPU(
            format="  {freq_current} GHz ({load_percent}%)",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Memory(
            format="  {MemUsed:.2f}G / {MemTotal:.0f}G ({MemPercent}%)",
            measure_mem='G',
            **decoration_group
        ),
        widget.Spacer(4),
        # NB Systray is incompatible with Wayland, consider using \
        # StatusNotifier instead
        extra_widgets.KeyboardLayout(
            fmt='⌨  {}',
            configured_keyboards=['us', 'br'],
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Systray(**decoration_group),
        extra_widgets.Clock(
            format="  %Y-%m-%d %a %H:%M:%S",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.TextBox(
            '⏻ ',
            **decoration_group
        ),

    ]


def second_bar():
    return [
        extra_widgets.TextBox(
            '󰣇',
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(menu)},
            **decoration_group,
        ),
        extra_widgets.CurrentLayout(
            padding_y=6,
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.GroupBox(
            padding_y=6,
            highlight_method='block',
            **decoration_group
        ),
        widget.Prompt(),
        widget.Spacer(4),
        extra_widgets.WindowName(
            format="  {name}",
            max_chars=30,
            **decoration_group
        ),
        # Left
        widget.Spacer(4),
        extra_widgets.Net(
            fmt="  {}",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Bluetooth(
            format="󰂯  {name}({battery_level}%)",
            **decoration_group
        ),
        widget.Spacer(4),
        # Battery
        extra_widgets.Battery(
            format="  {percent:2.0%} ({hour:d}:{min:02d}) {watt:.2f}W",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.CPU(
            format="  {freq_current} GHz ({load_percent}%)",
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Memory(
            format="  {MemUsed:.2f}G / {MemTotal:.0f}G ({MemPercent}%)",
            measure_mem='G',
            **decoration_group
        ),
        widget.Spacer(4),
        # NB Systray is incompatible with Wayland, consider using \
        # StatusNotifier instead
        extra_widgets.KeyboardLayout(
            fmt='⌨  {}',
            configured_keyboards=['us', 'br'],
            **decoration_group
        ),
        widget.Spacer(4),
        extra_widgets.Clock(
            format="  %Y-%m-%d %a %H:%M:%S",
            **decoration_group
        ),
        widget.Spacer(4),

    ]


def init_screens():
    return [
        Screen(
            wallpaper="~/.wallpapers/archlinux_1.jpg",
            wallpaper_mode="fill",
            top=bar.Bar(
                main_bar(),
                30,
                background="#00000000",
                opacity=1,
                border_width=[6, 6, 6, 6],  # Draw top and bottom borders
                border_color=["#00000000", "#00000000", "#00000000", "#00000000"]
            )
        ),
        Screen(
            wallpaper="~/.wallpapers/archlinux_1.jpg",
            wallpaper_mode="fill",
            top=bar.Bar(
                second_bar(),
                25,
                background="#00000000",
                opacity=1,
                border_width=[6, 6, 6, 6],  # Draw top and bottom borders
                border_color=["00000000", "00000000", "00000000", "00000000"]
            )
        ),
    ]
