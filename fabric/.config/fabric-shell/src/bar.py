"""StatusBar — mirrors the AGS bar layout exactly.

Layout (matches astal/.config/ags/widget/Bar.tsx):
  LEFT:   Apps · Workspaces · Music
  CENTER: Calendar (date/time with calendar popup)
  RIGHT:  AiUsage · Updates · Cpu · Memory · Gpu · Temperature ·
          Wifi · Bluetooth · Volume · Brightness · Battery · KbLayout · Power
"""

from fabric.hyprland.widgets import HyprlandWorkspaces, WorkspaceButton
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.wayland import WaylandWindow as Window

try:
    from .launcher import AppLauncher
    from .widgets import (
        AiUsageWidget,
        BatteryWidget,
        BluetoothWidget,
        BrightnessWidget,
        CpuWidget,
        DateWidget,
        GpuWidget,
        KeyboardLayoutWidget,
        LauncherButton,
        MemoryWidget,
        MusicWidget,
        PowerWidget,
        TemperatureWidget,
        UpdatesWidget,
        VolumeWidget,
        WifiWidget,
    )
except ImportError:
    from launcher import AppLauncher
    from widgets import (
        AiUsageWidget,
        BatteryWidget,
        BluetoothWidget,
        BrightnessWidget,
        CpuWidget,
        DateWidget,
        GpuWidget,
        KeyboardLayoutWidget,
        LauncherButton,
        MemoryWidget,
        MusicWidget,
        PowerWidget,
        TemperatureWidget,
        UpdatesWidget,
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
            margin="8px 8px -2px 8px",
            exclusivity="auto",
            monitor=monitor,
            visible=False,
        )

        self.launcher = launcher

        # ─── LEFT: Apps · Workspaces · Music ───────────────────────────────
        left = Box(
            name="start-container",
            spacing=3,
            orientation="h",
            children=[
                LauncherButton(self.launcher.toggle),
                HyprlandWorkspaces(
                    name="workspaces",
                    spacing=4,
                    buttons_factory=lambda ws_id: (
                        WorkspaceButton(id=ws_id, label=str(ws_id))
                        if ws_id > 0
                        else None
                    ),
                ),
                MusicWidget(monitor=monitor_id),
            ],
        )

        # ─── CENTER: Calendar (date/time) ──────────────────────────────────
        date = DateWidget(monitor=monitor_id)
        center = Box(
            name="center-container",
            spacing=8,
            orientation="h",
            h_align="center",
            h_expand=True,
            children=[date],
        )

        # ─── RIGHT: system widgets in AGS order ────────────────────────────
        right = Box(
            name="end-container",
            spacing=3,
            orientation="h",
            children=[
                AiUsageWidget(monitor=monitor_id),
                UpdatesWidget(monitor=monitor_id),
                CpuWidget(monitor=monitor_id),
                MemoryWidget(monitor=monitor_id),
                GpuWidget(monitor=monitor_id),
                TemperatureWidget(monitor=monitor_id),
                WifiWidget(monitor=monitor_id),
                BluetoothWidget(monitor=monitor_id),
                VolumeWidget(monitor=monitor_id),
                BrightnessWidget(monitor=monitor_id),
                BatteryWidget(monitor=monitor_id),
                KeyboardLayoutWidget(monitor=monitor_id),
                PowerWidget(monitor=monitor_id),
            ],
        )

        self.children = CenterBox(
            name="bar-inner",
            start_children=left,
            center_children=center,
            end_children=right,
        )

        self.show_all()
