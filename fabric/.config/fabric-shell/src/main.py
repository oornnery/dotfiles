import gi

gi.require_version("Gdk", "3.0")

from fabric.utils import get_relative_path
from gi.repository import Gdk

try:
    from .bar import StatusBar
    from .launcher import AppLauncher
except ImportError:
    from bar import StatusBar
    from launcher import AppLauncher

from fabric import Application

if __name__ == "__main__":
    launcher = AppLauncher()

    display = Gdk.Display.get_default()
    monitor_count = display.get_n_monitors() if display is not None else 1
    bars = [
        StatusBar(launcher=launcher, monitor=i) for i in range(max(1, monitor_count))
    ]

    app = Application("fabric-shell", *bars, launcher)
    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
