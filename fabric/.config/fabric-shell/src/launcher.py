import operator
from collections.abc import Iterator

from fabric.utils import DesktopApp, get_desktop_applications, idle_add, remove_handler
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window


class AppLauncher(Window):
    def __init__(self, **kwargs):
        super().__init__(
            name="app-launcher",
            layer="top",
            anchor="center",
            exclusivity="none",
            keyboard_mode="on-demand",
            visible=False,
            all_visible=False,
            **kwargs,
        )

        self._arranger_handler: int = 0
        self._all_apps = get_desktop_applications()
        self._is_open = False

        self.viewport = Box(name="launcher-viewport", spacing=4, orientation="v")

        self.search_entry = Entry(
            name="launcher-search",
            placeholder="Buscar apps...",
            h_expand=True,
            notify_text=lambda entry, *_: self.arrange_viewport(entry.get_text()),
        )

        self.scrolled_window = ScrolledWindow(
            min_content_size=(520, 420),
            max_content_size=(720, 520),
            child=self.viewport,
        )

        self.add(
            Box(
                name="launcher-root",
                spacing=8,
                orientation="v",
                children=[
                    Box(
                        name="launcher-header",
                        spacing=8,
                        orientation="h",
                        children=[
                            self.search_entry,
                            Button(
                                name="launcher-close",
                                image=Image(icon_name="window-close-symbolic"),
                                on_clicked=lambda *_: self.hide_launcher(),
                            ),
                        ],
                    ),
                    self.scrolled_window,
                ],
            )
        )

        self.add_keybinding("escape", lambda: self.hide_launcher())
        self.show_all()
        self.hide()

    def toggle(self):
        if self._is_open:
            self.hide_launcher()
        else:
            self.show_launcher()

    def show_launcher(self):
        self._is_open = True
        self.show_all()
        self.search_entry.set_text("")
        self.arrange_viewport("")
        self.search_entry.grab_focus()

    def hide_launcher(self):
        self._is_open = False
        self.hide()

    def arrange_viewport(self, query: str = ""):
        if self._arranger_handler:
            remove_handler(self._arranger_handler)

        self.viewport.children = []

        filtered_apps_iter = iter(
            [
                app
                for app in self._all_apps
                if query.casefold()
                in (
                    (app.display_name or "")
                    + " "
                    + (app.name or "")
                    + " "
                    + (app.generic_name or "")
                ).casefold()
            ]
        )

        should_resize = operator.length_hint(filtered_apps_iter) == len(self._all_apps)

        self._arranger_handler = idle_add(
            lambda *args: (
                self.add_next_application(*args)
                or (self.resize_viewport() if should_resize else False)
            ),
            filtered_apps_iter,
            pin=True,
        )
        return False

    def add_next_application(self, apps_iter: Iterator[DesktopApp]):
        if not (app := next(apps_iter, None)):
            return False
        self.viewport.add(self.bake_application_slot(app))
        return True

    def resize_viewport(self):
        self.scrolled_window.set_min_content_width(self.viewport.get_allocation().width)  # type: ignore
        return False

    def bake_application_slot(self, app: DesktopApp, **kwargs) -> Button:
        return Button(
            name="launcher-item",
            child=Box(
                orientation="h",
                spacing=12,
                children=[
                    Image(pixbuf=app.get_icon_pixbuf(), h_align="start", size=28),
                    Box(
                        orientation="v",
                        spacing=2,
                        children=[
                            Label(
                                name="launcher-item-title",
                                label=app.display_name or "Unknown",
                                h_align="start",
                            ),
                            Label(
                                name="launcher-item-subtitle",
                                label=app.generic_name or app.name or "",
                                h_align="start",
                            ),
                        ],
                    ),
                ],
            ),
            tooltip_text=app.description,
            on_clicked=lambda *_: (app.launch(), self.hide_launcher()),
            **kwargs,
        )
