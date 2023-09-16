from libqtile import widget
from qtile_extras.widget.decorations import BorderDecoration
from ..asserts import colors

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


# 

def separator(
    text: str = '|',
    font: str = "Ubuntu Mono",
    foreground: str = colors[1],
    padding: int = 2,
    font_size: int = 14
    ) -> widget.TextBox: 
    return widget.TextBox(
        text = text,
        font = font,
        foreground = foreground,
        padding = padding,
        fontsize = font_size
        )

def space(
    length: int = 8, 
    background: str = colors[0]
    ) -> widget.Spacer:
    return widget.Spacer(
        length = length,
        background = background
    )
    
