import gi

gi.require_version("Gdk", "3.0")

from pathlib import Path

from fabric.utils import get_relative_path
from gi.repository import Gdk

try:
    from .bar import StatusBar
    from .launcher import AppLauncher
except ImportError:
    from bar import StatusBar
    from launcher import AppLauncher

from fabric import Application


def _load_combined_css() -> str:
    """Concatenate theme.css + style.css so fabric's :vars preprocessor
    sees both in the same source. theme.css alone uses non-standard `:vars`
    syntax that GTK's CSS parser rejects when loaded via @import; merging
    here keeps the var resolution inside fabric's pipeline."""
    base = Path(get_relative_path("."))
    theme_path = base / "theme.css"
    style_path = base / "style.css"
    parts = []
    if theme_path.exists():
        parts.append(theme_path.read_text(encoding="utf-8"))
    parts.append(style_path.read_text(encoding="utf-8"))
    return "\n".join(parts)


if __name__ == "__main__":
    launcher = AppLauncher()

    display = Gdk.Display.get_default()
    monitor_count = display.get_n_monitors() if display is not None else 1
    bars = [
        StatusBar(launcher=launcher, monitor=i) for i in range(max(1, monitor_count))
    ]

    app = Application("fabric-shell", *bars, launcher)
    app.set_stylesheet_from_string(_load_combined_css())
    app.run()
