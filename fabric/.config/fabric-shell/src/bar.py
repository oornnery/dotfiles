from fabric.hyprland.widgets import (
    HyprlandActiveWindow,
    HyprlandWorkspaces,
    WorkspaceButton,
)
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.wayland import WaylandWindow as Window

try:
    from .launcher import AppLauncher
    from .widgets import (
        BatteryWidget,
        BluetoothWidget,
        BrightnessWidget,
        CpuWidget,
        DateWidget,
        KeyboardLayoutWidget,
        LauncherButton,
        MemoryWidget,
        VolumeWidget,
        WifiWidget,
    )
except ImportError:
    from launcher import AppLauncher
    from widgets import (
        BatteryWidget,
        BluetoothWidget,
        BrightnessWidget,
        CpuWidget,
        DateWidget,
        KeyboardLayoutWidget,
        LauncherButton,
        MemoryWidget,
        VolumeWidget,
        WifiWidget,
    )


class StatusBar(Window):
    def __init__(self, launcher: AppLauncher, monitor: int | None = None):
        monitor_id = monitor if monitor is not None else 0

        super().__init__(
            title=f"fabric-bar-{monitor_id}",
            name=f"bar-{monitor_id}",
            layer="top",
            anchor="left top right",
            margin="10px 10px -2px 10px",
            exclusivity="auto",
            monitor=monitor,
            visible=False,
        )

        self.launcher = launcher

        left = Box(
            name="start-container",
            spacing=8,
            orientation="h",
            children=[
                LauncherButton(self.launcher.toggle),
                HyprlandWorkspaces(
                    name="workspaces",
                    spacing=4,
                    buttons_factory=lambda ws_id: (
                        WorkspaceButton(
                            id=ws_id,
                            label=str(ws_id),
                        )
                        if ws_id > 0
                        else None
                    ),
                ),
            ],
        )

        center = Box(
            name="center-container",
            spacing=8,
            orientation="h",
            h_align="center",
            h_expand=True,
            children=[
                HyprlandActiveWindow(name="active-window"),
            ],
        )

        wifi = WifiWidget(monitor=monitor_id)
        bluetooth = BluetoothWidget(monitor=monitor_id)
        brightness = BrightnessWidget(monitor=monitor_id)
        volume = VolumeWidget(monitor=monitor_id)
        memory = MemoryWidget(monitor=monitor_id)
        cpu = CpuWidget(monitor=monitor_id)
        battery = BatteryWidget(monitor=monitor_id)
        keyboard_layout = KeyboardLayoutWidget(monitor=monitor_id)
        date = DateWidget(monitor=monitor_id)

        right = Box(
            name="end-container",
            spacing=6,
            orientation="h",
            children=[
                wifi,
                bluetooth,
                brightness,
                volume,
                memory,
                cpu,
                battery,
                keyboard_layout,
                date,
            ],
        )

        self.children = CenterBox(
            name="bar-inner",
            start_children=left,
            center_children=center,
            end_children=right,
        )

        self.show_all()
