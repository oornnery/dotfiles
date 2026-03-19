import json
import os
import shlex
import subprocess
import time
from pathlib import Path
from typing import Callable

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")

from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.label import Label
from fabric.widgets.scale import Scale
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window
from gi.repository import Gdk, GLib, Gtk

from fabric import Fabricator


def run(cmd: str) -> str:
    try:
        result = subprocess.run(
            shlex.split(cmd),
            capture_output=True,
            text=True,
            check=False,
        )
        return (result.stdout or "").strip()
    except Exception:
        return ""


def safe_int(value: str, default: int = 0) -> int:
    try:
        return int(float(value))
    except Exception:
        return default


def shorten(text: str, limit: int = 12) -> str:
    txt = (text or "").strip()
    if len(txt) <= limit:
        return txt
    return txt[: limit - 1] + "…"


def read_meminfo() -> dict[str, int]:
    data: dict[str, int] = {}
    try:
        with open("/proc/meminfo", encoding="utf-8") as f:
            for line in f:
                if ":" not in line:
                    continue
                key, rest = line.split(":", 1)
                parts = rest.strip().split()
                if not parts:
                    continue
                data[key] = safe_int(parts[0], 0)
    except Exception:
        return {}
    return data


def kib_to_gib(kib: int) -> float:
    return kib / (1024.0 * 1024.0)


def read_cpu_snapshot() -> list[tuple[int, int]]:
    """Return [(total, idle)] for cpu aggregate and each core from /proc/stat."""
    out: list[tuple[int, int]] = []
    try:
        with open("/proc/stat", encoding="utf-8") as f:
            for line in f:
                if not line.startswith("cpu"):
                    break
                parts = line.split()
                if not parts[0].startswith("cpu"):
                    continue
                nums = [int(v) for v in parts[1:8]]
                idle = nums[3] + nums[4]
                total = sum(nums)
                out.append((total, idle))
    except Exception:
        return []
    return out


def cpu_usage_from_snapshots(
    prev: list[tuple[int, int]], curr: list[tuple[int, int]]
) -> list[int]:
    values: list[int] = []
    if not prev or not curr:
        return values

    n = min(len(prev), len(curr))
    for i in range(n):
        p_total, p_idle = prev[i]
        c_total, c_idle = curr[i]
        dt = max(1, c_total - p_total)
        di = max(0, c_idle - p_idle)
        busy = max(0.0, min(100.0, (dt - di) * 100.0 / dt))
        values.append(int(round(busy)))
    return values


class PopupManager:
    active: "PopupWindow | None" = None

    @classmethod
    def toggle(cls, popup: "PopupWindow", anchor_widget: Gtk.Widget | None = None):
        if cls.active is popup and popup.get_visible():
            popup.hide_popup()
            cls.active = None
            return

        if cls.active is not None and cls.active is not popup:
            cls.active.hide_popup()

        popup.show_popup(anchor_widget)
        cls.active = popup

    @classmethod
    def close_active(cls):
        if cls.active is not None:
            cls.active.hide_popup()
            cls.active = None


class PopupWindow(Window):
    def __init__(
        self,
        title: str,
        name: str,
        monitor: int,
        child: Gtk.Widget,
    ):
        super().__init__(
            title=title,
            name=name,
            layer="overlay",
            anchor="top left",
            margin="34px 10px 0px 0px",
            exclusivity="none",
            keyboard_mode="exclusive",
            monitor=monitor,
            visible=False,
        )
        self.monitor_index = monitor
        self._live_timer_id: int | None = None
        self.set_accept_focus(True)
        self.add_events(Gdk.EventMask.FOCUS_CHANGE_MASK)
        self.connect("focus-out-event", lambda *_: self.hide_popup())
        self.add(child)
        self.add_keybinding("escape", lambda *_: PopupManager.close_active())

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        PopupManager.toggle(self, anchor_widget)

    def show_popup(self, anchor_widget: Gtk.Widget | None = None):
        if anchor_widget is not None:
            self.position_near(anchor_widget)
        self.show_all()
        self.present()
        self.on_popup_shown()

    def hide_popup(self):
        self.on_popup_hidden()
        self.hide()
        if PopupManager.active is self:
            PopupManager.active = None

    def on_popup_shown(self):
        """Hook for subclasses that need periodic updates while visible."""

    def on_popup_hidden(self):
        if self._live_timer_id is not None:
            GLib.source_remove(self._live_timer_id)
            self._live_timer_id = None

    def start_live_updates(self, interval_ms: int, callback: Callable[[], None]):
        if self._live_timer_id is not None:
            GLib.source_remove(self._live_timer_id)
            self._live_timer_id = None

        def _tick():
            if not self.get_visible():
                self._live_timer_id = None
                return False
            callback()
            return True

        self._live_timer_id = GLib.timeout_add(interval_ms, _tick)

    def position_near(self, anchor_widget: Gtk.Widget):
        top_level = anchor_widget.get_toplevel()
        if not isinstance(top_level, Gtk.Window):
            return

        translated = anchor_widget.translate_coordinates(top_level, 0, 0)
        if translated is None:
            return
        rel_x, rel_y = translated

        alloc = anchor_widget.get_allocation()
        # Layer-shell windows are monitor-local. Clamp position so popup never
        # overflows the monitor bounds on the right/bottom edges.
        local_x = max(0, int(rel_x))
        local_y = max(0, int(rel_y + alloc.height + 4))

        popup_w = 320
        popup_h = 220
        child = self.get_child()
        if child is not None:
            try:
                min_w, nat_w = child.get_preferred_width()
                min_h, nat_h = child.get_preferred_height()
                popup_w = max(min_w, nat_w, popup_w)
                popup_h = max(min_h, nat_h, popup_h)
            except Exception:
                pass

        display = Gdk.Display.get_default()
        if display is not None:
            monitor = display.get_monitor(self.monitor_index)
            if monitor is not None:
                geo = monitor.get_geometry()
                pad = 8
                max_x = max(pad, geo.width - popup_w - pad)
                max_y = max(pad, geo.height - popup_h - pad)
                local_x = min(local_x, max_x)
                local_y = min(local_y, max_y)

        self.margin = f"{local_y}px 0px 0px {local_x}px"


class PollLabel(Button):
    def __init__(
        self,
        name: str,
        icon: str,
        poll_from: Callable[[], str],
        interval: int = 2000,
        on_click: Callable[[Gtk.Widget], None] | None = None,
        on_scroll: Callable[[int], None] | None = None,
        **kwargs,
    ):
        self._on_scroll = on_scroll

        self.icon_label = Label(label=icon, name=f"{name}-icon") if icon else None
        self.text_label = Label(label="...", name=f"{name}-text")

        children = [self.text_label]
        if self.icon_label is not None:
            children.insert(0, self.icon_label)

        content = Box(spacing=6, orientation="h", children=children)

        super().__init__(
            name=name,
            child=content,
            **kwargs,
        )

        self._poller = Fabricator(
            interval=interval,
            poll_from=lambda *_: poll_from(),
            on_changed=lambda *_args: self._update_text(_args[-1]),
        )

        if on_click:
            self.connect("clicked", lambda *_: on_click(self))

        if self._on_scroll is not None:
            self.add_events(Gdk.EventMask.SCROLL_MASK)
            self.connect("scroll-event", self._handle_scroll)

    def _update_text(self, text: str):
        self.text_label.set_label(text or "--")

    def _handle_scroll(self, _widget, event):
        if self._on_scroll is None:
            return False

        if event.direction == Gdk.ScrollDirection.UP:
            self._on_scroll(1)
            return True
        if event.direction == Gdk.ScrollDirection.DOWN:
            self._on_scroll(-1)
            return True
        return False


class BatteryWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = BatteryPopup(monitor)
        super().__init__(
            name="battery-widget",
            icon="󰁹",
            interval=15000,
            poll_from=self.get_battery,
            on_click=self.popup.toggle,
        )

    def get_battery(self) -> str:
        cap = self._read_ps_file("capacity")
        status = self._read_ps_file("status")
        if not cap:
            return "AC"
        pct = safe_int(cap, 0)
        if status.lower().startswith("charging"):
            return f"{pct}% carregando"
        return f"{pct}%"

    @staticmethod
    def _read_ps_file(name: str) -> str:
        base = Path("/sys/class/power_supply")
        if not base.exists():
            return ""
        for p in base.iterdir():
            if p.name.startswith("BAT"):
                try:
                    return (p / name).read_text(encoding="utf-8").strip()
                except Exception:
                    return ""
        return ""


class MemoryWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = MemoryPopup(monitor)
        super().__init__(
            name="memory-widget",
            icon="󰍛",
            interval=3500,
            poll_from=self.get_memory,
            on_click=self.popup.toggle,
        )

    def get_memory(self) -> str:
        info = read_meminfo()
        total = info.get("MemTotal", 0)
        available = info.get("MemAvailable", 0)

        if total <= 0:
            return "--"
        used = max(0, total - available)
        pct = int(round((used * 100.0) / total))
        return f"{pct}%"


class CpuWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self._prev = read_cpu_snapshot()
        self.popup = CpuPopup(monitor)
        super().__init__(
            name="cpu-widget",
            icon="󰻠",
            interval=1500,
            poll_from=self.get_cpu,
            on_click=self.popup.toggle,
        )

    def get_cpu(self) -> str:
        curr = read_cpu_snapshot()
        usage = cpu_usage_from_snapshots(self._prev, curr)
        self._prev = curr
        if not usage:
            return "--"
        # usage[0] is aggregate cpu
        return f"{usage[0]}%"


class VolumeWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = VolumePopup(monitor)
        super().__init__(
            name="volume-widget",
            icon="󰕾",
            interval=2500,
            poll_from=self.get_volume,
            on_click=self.popup.toggle,
            on_scroll=self.on_scroll,
        )

    def get_volume(self) -> str:
        value = run('sh -lc "wpctl get-volume @DEFAULT_AUDIO_SINK@"')
        if not value:
            return "--"
        # Ex.: Volume: 0.42 [MUTED]
        muted = "MUTED" in value.upper()
        parts = value.split()
        vol = 0
        if len(parts) >= 2:
            try:
                vol = int(float(parts[1]) * 100)
            except Exception:
                vol = 0
        if muted:
            return f"{vol}% mute"
        return f"{vol}%"

    def on_scroll(self, direction: int):
        if direction > 0:
            run('sh -lc "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"')
        else:
            run('sh -lc "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"')


class BrightnessWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = BrightnessPopup(monitor)
        super().__init__(
            name="brightness-widget",
            icon="󰃠",
            interval=4000,
            poll_from=self.get_brightness,
            on_click=self.popup.toggle,
            on_scroll=self.on_scroll,
        )

    def get_brightness(self) -> str:
        out = run("sh -lc 'brightnessctl -m 2>/dev/null'")
        if not out:
            return "--"
        # machine format, último campo costuma ser "50%"
        parts = out.split(",")
        if len(parts) >= 4:
            return parts[3]
        return "--"

    def on_scroll(self, direction: int):
        if direction > 0:
            run("sh -lc 'brightnessctl set 5%+'")
        else:
            run("sh -lc 'brightnessctl set 5%-'")


class WifiWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = WifiPopup(monitor)
        super().__init__(
            name="wifi-widget",
            icon="󰤨",
            interval=8000,
            poll_from=self.get_wifi,
            on_click=self.popup.toggle,
        )

    def get_wifi(self) -> str:
        active = run(
            "sh -lc \"nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | head -n1\""
        )
        if active:
            ssid = active.split(":", 1)[1] if ":" in active else active
            return shorten(ssid or "connected", 12)

        state = run("sh -lc 'nmcli -t -f WIFI general'")
        if state.lower() == "enabled":
            return "on"
        return "off"


class BluetoothWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = BluetoothPopup(monitor)
        super().__init__(
            name="bluetooth-widget",
            icon="󰂯",
            interval=8000,
            poll_from=self.get_bluetooth,
            on_click=self.popup.toggle,
        )

    def get_bluetooth(self) -> str:
        show = run("sh -lc 'bluetoothctl show 2>/dev/null'")
        if not show:
            return "off"

        powered = "Powered: yes" in show
        if not powered:
            return "off"

        devices = run('sh -lc "bluetoothctl devices Connected 2>/dev/null | head -n1"')
        if devices:
            # Device XX:XX Nome
            parts = devices.split(" ", 2)
            if len(parts) == 3:
                return shorten(parts[2], 12)
            return "connected"
        return "on"


class KeyboardLayoutWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.monitor = monitor
        super().__init__(
            name="keyboard-layout-widget",
            icon="󰌌",
            interval=3000,
            poll_from=self.get_layout,
            on_click=self.toggle_layout,
        )

    def _devices_json(self) -> dict:
        try:
            result = subprocess.run(
                ["hyprctl", "devices", "-j"],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                return {}
            return json.loads((result.stdout or "").strip() or "{}")
        except Exception:
            return {}

    def _keyboards(self) -> list[dict]:
        data = self._devices_json()
        keyboards = data.get("keyboards") if isinstance(data, dict) else None
        if not isinstance(keyboards, list):
            return []
        return [k for k in keyboards if isinstance(k, dict)]

    def _primary_keyboard(self) -> dict | None:
        keyboards = self._keyboards()
        for kb in keyboards:
            if kb.get("main") is True:
                return kb
        return keyboards[0] if keyboards else None

    def _configured_layouts(self) -> list[str]:
        try:
            result = subprocess.run(
                ["hyprctl", "getoption", "input:kb_layout", "-j"],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode == 0:
                raw = (result.stdout or "").strip()
                if raw:
                    data = json.loads(raw)
                    value = (data.get("str") or "").strip()
                    if value:
                        return [p.strip() for p in value.split(",") if p.strip()]
        except Exception:
            pass
        return []

    def get_layout(self) -> str:
        kb = self._primary_keyboard()
        if not kb:
            return "--"

        layout_raw = (kb.get("layout") or "").strip()
        active_idx = kb.get("active_layout_index")
        if layout_raw and isinstance(active_idx, int):
            parts = [p.strip() for p in layout_raw.split(",") if p.strip()]
            if 0 <= active_idx < len(parts):
                return parts[active_idx].upper()

        keymap = (kb.get("active_keymap") or "").strip()
        if not keymap:
            return "--"

        if "(" in keymap and ")" in keymap:
            start = keymap.rfind("(")
            end = keymap.rfind(")")
            if start != -1 and end > start:
                tag = keymap[start + 1 : end].strip()
                if tag:
                    return tag[:4].upper()

        first = keymap.split()[0].strip()
        if not first:
            return "--"
        return first[:4].upper()

    def toggle_layout(self, _widget):
        layouts = self._configured_layouts()
        if len(layouts) < 2:
            return

        kb = self._primary_keyboard()
        if not kb:
            return

        name = (kb.get("name") or "").strip()
        if not name:
            return
        subprocess.run(
            ["hyprctl", "switchxkblayout", name, "next"],
            capture_output=True,
            text=True,
            check=False,
        )

        self._update_text(self.get_layout())


class WifiPopup(PopupWindow):
    def __init__(self, monitor: int):
        self.status = Label(name="net-status", label="Wi-Fi: --")
        self.action = Label(name="net-action", label="")
        self.selected_ssid = ""
        self._syncing_switch = False

        self.wifi_switch = Gtk.Switch()
        self.wifi_switch.set_name("net-toggle")
        self.wifi_switch.connect("state-set", self._on_wifi_switch)

        self.password_entry = Entry(
            name="net-entry",
            placeholder="Senha da rede selecionada (opcional)",
            h_expand=True,
            visibility=False,
        )

        self.list_box = Box(name="net-list", orientation="v", spacing=4)
        self.list_scroll = ScrolledWindow(
            min_content_size=(420, 260),
            max_content_size=(520, 360),
            child=self.list_box,
        )

        toggle_row = Box(
            orientation="h",
            spacing=8,
            children=[
                Label(name="control-subtitle", label="Wi-Fi"),
                self.wifi_switch,
            ],
        )

        controls = Box(
            orientation="h",
            spacing=6,
            children=[
                Button(label="Atualizar", on_clicked=lambda *_: self.sync()),
            ],
        )

        root = Box(
            name="control-popup-network",
            orientation="v",
            spacing=8,
            children=[
                Label(name="control-title", label="Wi-Fi"),
                self.status,
                self.action,
                toggle_row,
                self.password_entry,
                controls,
                Label(name="control-subtitle", label="Redes disponiveis"),
                self.list_scroll,
            ],
        )
        super().__init__("fabric-wifi-popup", "wifi-popup", monitor, root)

    def on_popup_shown(self):
        self.start_live_updates(2500, self.sync)

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def set_action(self, msg: str):
        self.action.set_label(msg)

    def _on_wifi_switch(self, _switch, state):
        if self._syncing_switch:
            return False
        self.set_wifi(bool(state))
        return False

    def _wifi_enabled(self) -> bool:
        return run("nmcli -t -f WIFI general").strip().lower() == "enabled"

    def _wifi_device(self) -> str:
        out = run("nmcli -t --separator '|' -f DEVICE,TYPE,STATE device status")
        for line in out.splitlines():
            parts = line.split("|")
            if len(parts) >= 3 and parts[1] == "wifi":
                return parts[0]
        return ""

    def _connected_ssid(self) -> str:
        out = run("nmcli -t --separator '|' -f ACTIVE,SSID dev wifi")
        for line in out.splitlines():
            parts = line.split("|")
            if len(parts) >= 2 and parts[0] == "yes":
                return parts[1]
        return ""

    def set_wifi(self, enabled: bool):
        cmd = ["nmcli", "radio", "wifi", "on" if enabled else "off"]
        subprocess.run(cmd, capture_output=True, text=True, check=False)
        self.sync()

    def connect_ssid(self, ssid: str):
        if not ssid:
            return
        self.selected_ssid = ssid

        password = self.password_entry.get_text().strip()
        cmd = ["nmcli", "device", "wifi", "connect", ssid]
        if password:
            cmd += ["password", password]

        res = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if res.returncode == 0:
            self.set_action(f"Conectado: {ssid}")
        else:
            msg = (res.stderr or res.stdout or "Falha ao conectar").strip()
            self.set_action(shorten(msg, 96))
        self.sync()

    def disconnect_wifi(self):
        dev = self._wifi_device()
        if not dev:
            self.set_action("Dispositivo Wi-Fi nao encontrado")
            return
        res = subprocess.run(
            ["nmcli", "device", "disconnect", dev],
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0:
            self.set_action("Wi-Fi desconectado")
        else:
            msg = (res.stderr or res.stdout or "Falha ao desconectar").strip()
            self.set_action(shorten(msg, 96))
        self.sync()

    def _forget_by_name(self, ssid: str):
        out = run("nmcli -t --separator '|' -f NAME,TYPE connection show")
        for line in out.splitlines():
            parts = line.split("|")
            if len(parts) >= 2 and parts[0] == ssid and parts[1] == "802-11-wireless":
                subprocess.run(
                    ["nmcli", "connection", "delete", "id", ssid],
                    capture_output=True,
                    text=True,
                    check=False,
                )

    def _saved_ssids(self) -> set[str]:
        out = run("nmcli -t --separator '|' -f NAME,TYPE connection show")
        saved: set[str] = set()
        for line in out.splitlines():
            parts = line.split("|")
            if len(parts) >= 2 and parts[1] == "802-11-wireless":
                saved.add(parts[0])
        return saved

    def _build_row(
        self, active: bool, ssid: str, security: str, signal: str, saved: bool
    ) -> Gtk.Widget:
        ssid_label = ssid or "<oculta>"
        connected = active
        row_label = Label(
            name="net-row-label",
            label=f"{shorten(ssid_label, 22):<22}  {shorten(security or '--', 10):<10}  {signal:>3}%",
            h_align="start",
            h_expand=True,
        )

        if connected:
            connect_btn = Button(
                name="net-chip-btn",
                label="Desconectar",
                on_clicked=lambda *_: self.disconnect_wifi(),
            )
        else:
            connect_btn = Button(
                name="net-chip-btn",
                label="Conectar",
                on_clicked=lambda *_: self.connect_ssid(ssid),
            )

        actions: list[Gtk.Widget] = []
        if saved:
            actions.append(
                Button(
                    name="net-chip-btn-danger",
                    label="Esquecer",
                    on_clicked=lambda *_: self._forget_and_refresh(ssid),
                )
            )

        selected = bool(ssid and ssid == self.selected_ssid)
        select_btn = Button(
            name="net-chip-btn",
            label="Selecionado" if selected else "Selecionar",
            on_clicked=lambda *_: self._select(ssid),
        )
        if selected:
            select_btn.get_style_context().add_class("active")
        actions.extend([select_btn, connect_btn])

        return Box(
            name="net-row",
            orientation="h",
            spacing=6,
            children=[row_label, *actions],
        )

    def _select(self, ssid: str):
        self.selected_ssid = ssid
        self.set_action(f"Selecionada: {ssid}")
        self.sync()

    def _forget_and_refresh(self, ssid: str):
        self._forget_by_name(ssid)
        self.set_action(f"Rede esquecida: {ssid}")
        self.sync()

    def sync(self):
        enabled = self._wifi_enabled()
        self._syncing_switch = True
        self.wifi_switch.set_active(enabled)
        self._syncing_switch = False

        connected = self._connected_ssid()
        self.status.set_label(
            f"Wi-Fi: {'on' if enabled else 'off'} | conectado: {connected or '--'} | selecionada: {self.selected_ssid or '--'}"
        )

        if not enabled:
            self.list_box.children = [Label(name="net-empty", label="Wi-Fi desativado")]
            return

        out = run(
            "nmcli -t --separator '|' -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list --rescan auto"
        )
        saved_ssids = self._saved_ssids()
        rows: list[Gtk.Widget] = []
        for line in out.splitlines():
            parts = line.split("|")
            if len(parts) < 4:
                continue
            active = parts[0].strip() == "*"
            ssid = parts[1].strip()
            security = parts[2].strip() or "open"
            signal = parts[3].strip() or "0"
            rows.append(
                self._build_row(active, ssid, security, signal, ssid in saved_ssids)
            )

        if not rows:
            rows = [Label(name="net-empty", label="Nenhuma rede encontrada")]
        self.list_box.children = rows


class BluetoothPopup(PopupWindow):
    def __init__(self, monitor: int):
        self.status = Label(name="net-status", label="Bluetooth: --")
        self.action = Label(name="net-action", label="")
        self.selected_mac = ""
        self._syncing_switch = False

        self.bt_switch = Gtk.Switch()
        self.bt_switch.set_name("net-toggle")
        self.bt_switch.connect("state-set", self._on_bt_switch)

        self.pin_entry = Entry(
            name="net-entry",
            placeholder="PIN/Passkey para pareamento (opcional)",
            h_expand=True,
            visibility=False,
        )

        self.list_box = Box(name="net-list", orientation="v", spacing=4)
        self.list_scroll = ScrolledWindow(
            min_content_size=(420, 240),
            max_content_size=(520, 340),
            child=self.list_box,
        )

        toggle_row = Box(
            orientation="h",
            spacing=8,
            children=[
                Label(name="control-subtitle", label="Bluetooth"),
                self.bt_switch,
            ],
        )

        controls = Box(
            orientation="h",
            spacing=6,
            children=[
                Button(label="Atualizar", on_clicked=lambda *_: self.sync()),
                Button(label="Scan 8s", on_clicked=lambda *_: self.scan_short()),
            ],
        )

        root = Box(
            name="control-popup-network",
            orientation="v",
            spacing=8,
            children=[
                Label(name="control-title", label="Bluetooth"),
                self.status,
                self.action,
                toggle_row,
                self.pin_entry,
                controls,
                Label(name="control-subtitle", label="Dispositivos"),
                self.list_scroll,
            ],
        )
        super().__init__("fabric-bt-popup", "bt-popup", monitor, root)

    def on_popup_shown(self):
        self.start_live_updates(3000, self.sync)

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def _bt_run(self, script: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["bluetoothctl"],
            input=script,
            capture_output=True,
            text=True,
            check=False,
        )

    def set_action(self, msg: str):
        self.action.set_label(msg)

    def _on_bt_switch(self, _switch, state):
        if self._syncing_switch:
            return False
        self.set_power(bool(state))
        return False

    def _powered(self) -> bool:
        show = run("bluetoothctl show")
        return "Powered: yes" in show

    def set_power(self, enabled: bool):
        script = f"power {'on' if enabled else 'off'}\nquit\n"
        self._bt_run(script)
        self.sync()

    def scan_short(self):
        self._bt_run("scan on\n")
        GLib.timeout_add(8000, self._stop_scan_then_refresh)

    def _stop_scan_then_refresh(self):
        self._bt_run("scan off\nquit\n")
        self.sync()
        return False

    def _paired_set(self) -> set[str]:
        out = run("bluetoothctl paired-devices")
        devices: set[str] = set()
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 2 and parts[0] == "Device":
                devices.add(parts[1])
        return devices

    def _device_info(self, mac: str) -> dict[str, str]:
        out = run(f"bluetoothctl info {mac}")
        info: dict[str, str] = {"Connected": "no", "Trusted": "no"}
        for line in out.splitlines():
            ln = line.strip()
            if ln.startswith("Name:"):
                info["Name"] = ln.split(":", 1)[1].strip()
            elif ln.startswith("Connected:"):
                info["Connected"] = ln.split(":", 1)[1].strip()
            elif ln.startswith("Trusted:"):
                info["Trusted"] = ln.split(":", 1)[1].strip()
        return info

    def connect_device(self, mac: str):
        pin = self.pin_entry.get_text().strip()
        script = "agent KeyboardOnly\ndefault-agent\n"
        script += f"pair {mac}\n"
        if pin:
            script += f"{pin}\n"
        script += f"trust {mac}\nconnect {mac}\nquit\n"
        res = self._bt_run(script)
        msg = (res.stderr or res.stdout or "acao enviada").strip()
        self.set_action(shorten(msg, 96))
        self.sync()

    def disconnect_device(self, mac: str):
        self._bt_run(f"disconnect {mac}\nquit\n")
        self.set_action(f"Desconectado: {mac}")
        self.sync()

    def forget_device(self, mac: str):
        self._bt_run(f"remove {mac}\nquit\n")
        self.set_action(f"Removido: {mac}")
        self.sync()

    def _build_row(
        self, mac: str, name: str, connected: bool, paired: bool
    ) -> Gtk.Widget:
        label = Label(
            name="net-row-label",
            label=f"{shorten(name, 20):<20}  {mac}  {'conn' if connected else 'disc'}  {'paired' if paired else 'new'}",
            h_align="start",
            h_expand=True,
        )
        selected = bool(mac and mac == self.selected_mac)
        select_btn = Button(
            label="Selecionado" if selected else "Selecionar",
            on_clicked=lambda *_: self._select(mac),
        )
        if connected:
            conn_btn = Button(
                name="net-chip-btn",
                label="Desconectar",
                on_clicked=lambda *_: self.disconnect_device(mac),
            )
        else:
            conn_btn = Button(
                name="net-chip-btn",
                label="Conectar",
                on_clicked=lambda *_: self.connect_device(mac),
            )
        forget_btn = Button(
            name="net-chip-btn-danger",
            label="Esquecer",
            on_clicked=lambda *_: self.forget_device(mac),
        )
        select_btn.set_name("net-chip-btn")
        if selected:
            select_btn.get_style_context().add_class("active")

        return Box(
            name="net-row",
            orientation="h",
            spacing=6,
            children=[label, select_btn, conn_btn, forget_btn],
        )

    def _select(self, mac: str):
        self.selected_mac = mac
        self.set_action(f"Selecionado: {mac}")
        self.sync()

    def sync(self):
        powered = self._powered()
        self._syncing_switch = True
        self.bt_switch.set_active(powered)
        self._syncing_switch = False

        self.status.set_label(
            f"Bluetooth: {'on' if powered else 'off'} | selecionado: {self.selected_mac or '--'}"
        )

        if not powered:
            self.list_box.children = [
                Label(name="net-empty", label="Bluetooth desativado")
            ]
            return

        paired = self._paired_set()
        out = run("bluetoothctl devices")
        rows: list[Gtk.Widget] = []
        for line in out.splitlines():
            parts = line.split(" ", 2)
            if len(parts) < 3 or parts[0] != "Device":
                continue
            mac = parts[1]
            name = parts[2]
            info = self._device_info(mac)
            connected = info.get("Connected", "no") == "yes"
            rows.append(self._build_row(mac, name, connected, mac in paired))

        if not rows:
            rows = [Label(name="net-empty", label="Nenhum dispositivo encontrado")]
        self.list_box.children = rows


class LauncherButton(Button):
    def __init__(self, toggle_launcher: Callable[[], None]):
        super().__init__(
            name="launcher-button",
            label="󰣇 Apps",
            on_clicked=lambda *_: toggle_launcher(),
        )


class ActiveWindowWidget(PollLabel):
    def __init__(self):
        super().__init__(
            name="active-window",
            icon="",
            interval=1000,
            poll_from=self.get_active_window,
        )

    def get_active_window(self) -> str:
        raw = run("sh -lc 'hyprctl activewindow -j 2>/dev/null'")
        if not raw:
            return "Desktop"

        try:
            data = json.loads(raw)
            title = (data.get("title") or "").strip()
            if not title:
                return "Desktop"

            return shorten(title, 40)
        except Exception:
            return "Desktop"


class DateWidget(PollLabel):
    def __init__(self, monitor: int = 0):
        self.popup = CalendarPopup(monitor)
        super().__init__(
            name="date-time",
            icon="",
            interval=1000,
            poll_from=lambda: time.strftime("%A %d/%m %H:%M:%S"),
            on_click=self.popup.toggle,
        )


class MemoryPopup(PopupWindow):
    def __init__(self, monitor: int):
        self.summary_1 = Label(name="memcpu-summary", label="RAM: --")
        self.summary_2 = Label(name="memcpu-summary", label="Swap: --")
        self.table_header = Label(
            name="memcpu-table-header",
            label="PID     PROCESSO           RSS(MiB)   MEM%",
        )
        self.rows = [Label(name="memcpu-proc-row", label="--") for _ in range(5)]

        rows_box = Box(
            orientation="v",
            spacing=4,
            children=self.rows,
        )
        root = Box(
            name="control-popup-memcpu",
            orientation="v",
            spacing=8,
            children=[
                Label(name="control-title", label="Memoria RAM"),
                self.summary_1,
                self.summary_2,
                Label(name="control-subtitle", label="Top processos por RAM"),
                self.table_header,
                rows_box,
            ],
        )
        super().__init__("fabric-memory-popup", "memory-popup", monitor, root)

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def on_popup_shown(self):
        self.start_live_updates(1200, self.sync)

    def sync(self):
        info = read_meminfo()
        total = info.get("MemTotal", 0)
        avail = info.get("MemAvailable", 0)
        used = max(0, total - avail)
        swap_total = info.get("SwapTotal", 0)
        swap_free = info.get("SwapFree", 0)
        swap_used = max(0, swap_total - swap_free)

        if total > 0:
            self.summary_1.set_label(
                f"RAM: {kib_to_gib(used):.1f} GiB / {kib_to_gib(total):.1f} GiB ({(used * 100.0 / total):.1f}%)"
            )
        else:
            self.summary_1.set_label("RAM: --")

        if swap_total > 0:
            swap_pct = (swap_used * 100.0 / swap_total) if swap_total else 0.0
            self.summary_2.set_label(
                f"Swap: on {kib_to_gib(swap_used):.1f} GiB / {kib_to_gib(swap_total):.1f} GiB ({swap_pct:.1f}%)"
            )
        else:
            self.summary_2.set_label("Swap: off")

        out = run("sh -lc \"ps -eo pid,comm,rss,%mem --sort=-%mem | sed -n '2,6p'\"")
        lines = [ln.strip() for ln in out.splitlines() if ln.strip()]
        for i in range(5):
            if i < len(lines):
                parts = lines[i].split()
                if len(parts) >= 4:
                    pid = parts[0]
                    name = parts[1]
                    rss_kib = safe_int(parts[2], 0)
                    pct = parts[3]
                    self.rows[i].set_label(
                        f"{pid:>6}  {shorten(name, 16):<16}  {rss_kib / 1024.0:>7.1f}   {pct:>5}"
                    )
                else:
                    self.rows[i].set_label(shorten(lines[i], 44))
            else:
                self.rows[i].set_label("--")


class CpuPopup(PopupWindow):
    def __init__(self, monitor: int):
        self._prev = read_cpu_snapshot()
        self.core_labels: list[Label] = []
        self.core_rows = Box(orientation="v", spacing=6)
        self.summary_1 = Label(name="memcpu-summary", label="Usage: --")
        self.summary_2 = Label(name="memcpu-summary", label="Avg: -- -- --")
        self.table_header = Label(
            name="memcpu-table-header",
            label="PID     PROCESSO            CPU%    MEM%",
        )

        core_count = max(1, os.cpu_count() or 1)
        for i in range(core_count):
            lbl = Label(name="cpu-core-chip", label=f"C{i} --%")
            self.core_labels.append(lbl)

        self._rebuild_core_rows()

        self.top_rows = [Label(name="memcpu-proc-row", label="--") for _ in range(5)]
        top_box = Box(orientation="v", spacing=4, children=self.top_rows)

        root = Box(
            name="control-popup-memcpu",
            orientation="v",
            spacing=8,
            children=[
                Label(name="control-title", label="CPU"),
                self.summary_1,
                self.summary_2,
                Label(name="control-subtitle", label="Utilizacao por nucleo"),
                self.core_rows,
                Label(name="control-subtitle", label="Top processos por CPU"),
                self.table_header,
                top_box,
            ],
        )
        super().__init__("fabric-cpu-popup", "cpu-popup", monitor, root)

    def _rebuild_core_rows(self):
        for child in list(self.core_rows.get_children()):
            self.core_rows.remove(child)

        per_row = 4
        row_children: list[Gtk.Widget] = []
        for i, lbl in enumerate(self.core_labels):
            row_children.append(lbl)
            if len(row_children) == per_row or i == len(self.core_labels) - 1:
                row = Box(orientation="h", spacing=6, children=row_children)
                self.core_rows.add(row)
                row_children = []

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def on_popup_shown(self):
        self.start_live_updates(900, self.sync)

    def sync(self):
        curr = read_cpu_snapshot()
        usage = cpu_usage_from_snapshots(self._prev, curr)
        self._prev = curr

        if usage:
            self.summary_1.set_label(f"CPU: {usage[0]}%")
        else:
            self.summary_1.set_label("CPU: --")

        cores = usage[1:] if len(usage) > 1 else []
        if cores:
            mn = min(cores)
            avg = sum(cores) / len(cores)
            mx = max(cores)
            self.summary_2.set_label(f"Usage: {mn}% {avg:.1f}% {mx}%")
        else:
            self.summary_2.set_label("Usage: -- -- --")

        for i, lbl in enumerate(self.core_labels):
            val = cores[i] if i < len(cores) else 0
            lbl.set_label(f"C{i} {val}%")

        out = run("sh -lc \"ps -eo pid,comm,%cpu,%mem --sort=-%cpu | sed -n '2,6p'\"")
        lines = [ln.strip() for ln in out.splitlines() if ln.strip()]
        for i in range(5):
            if i < len(lines):
                parts = lines[i].split()
                if len(parts) >= 4:
                    pid = parts[0]
                    name = parts[1]
                    cpu_pct = parts[2]
                    mem_pct = parts[3]
                    self.top_rows[i].set_label(
                        f"{pid:>6}  {shorten(name, 16):<16}  {cpu_pct:>6}  {mem_pct:>6}"
                    )
                else:
                    self.top_rows[i].set_label(shorten(lines[i], 44))
            else:
                self.top_rows[i].set_label("--")


class VolumePopup(PopupWindow):
    def __init__(self, monitor: int):
        self._syncing = False
        self.slider = Scale(
            name="control-slider",
            min_value=0,
            max_value=100,
            value=50,
            draw_value=True,
            digits=0,
            h_expand=True,
        )
        self.slider.connect("value-changed", self.on_value_changed)

        root = Box(
            name="control-popup-slider",
            orientation="v",
            spacing=8,
            children=[Label(name="control-title", label="Volume"), self.slider],
        )
        super().__init__("fabric-volume-popup", "volume-popup", monitor, root)

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def sync(self):
        value = run('sh -lc "wpctl get-volume @DEFAULT_AUDIO_SINK@"')
        parts = value.split()
        if len(parts) >= 2:
            try:
                self._syncing = True
                self.slider.set_value(max(0, min(100, float(parts[1]) * 100)))
            except Exception:
                pass
            finally:
                self._syncing = False

    def on_value_changed(self, slider):
        if self._syncing:
            return
        val = slider.get_value() / 100.0
        run(f'sh -lc "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ {val:.2f}"')


class BrightnessPopup(PopupWindow):
    def __init__(self, monitor: int):
        self._syncing = False
        self.slider = Scale(
            name="control-slider",
            min_value=1,
            max_value=100,
            value=50,
            draw_value=True,
            digits=0,
            h_expand=True,
        )
        self.slider.connect("value-changed", self.on_value_changed)

        root = Box(
            name="control-popup-slider",
            orientation="v",
            spacing=8,
            children=[Label(name="control-title", label="Brilho"), self.slider],
        )
        super().__init__("fabric-brightness-popup", "brightness-popup", monitor, root)

    def toggle(self, anchor_widget: Gtk.Widget | None = None):
        self.sync()
        super().toggle(anchor_widget)

    def sync(self):
        out = run("sh -lc 'brightnessctl -m 2>/dev/null'")
        if out:
            parts = out.split(",")
            if len(parts) >= 4 and parts[3].endswith("%"):
                try:
                    self._syncing = True
                    self.slider.set_value(float(parts[3].rstrip("%")))
                except Exception:
                    pass
                finally:
                    self._syncing = False

    def on_value_changed(self, slider):
        if self._syncing:
            return
        value = int(slider.get_value())
        run(f"sh -lc 'brightnessctl set {value}%' ")


class CalendarPopup(PopupWindow):
    def __init__(self, monitor: int):
        calendar = Gtk.Calendar()
        root = Box(
            name="control-popup-calendar",
            orientation="v",
            spacing=6,
            children=[Label(name="control-title", label="Calendario"), calendar],
        )
        super().__init__("fabric-calendar-popup", "calendar-popup", monitor, root)


class BatteryPopup(PopupWindow):
    def __init__(self, monitor: int):
        self.profile_buttons: dict[str, Button] = {}
        self.status = Label(name="battery-profile-status", label="")

        saver_btn = Button(
            label="Economia",
            on_clicked=lambda *_: self.set_profile("power-saver"),
        )
        balanced_btn = Button(
            label="Balanceado",
            on_clicked=lambda *_: self.set_profile("balanced"),
        )
        perf_btn = Button(
            label="Performance",
            on_clicked=lambda *_: self.set_profile("performance"),
        )
        self.profile_buttons = {
            "power-saver": saver_btn,
            "balanced": balanced_btn,
            "performance": perf_btn,
        }

        buttons = Box(
            orientation="h",
            spacing=6,
            h_align="center",
            children=[saver_btn, balanced_btn, perf_btn],
        )
        root = Box(
            name="control-popup-battery",
            orientation="v",
            spacing=8,
            children=[
                Label(name="control-title", label="Plano de energia"),
                buttons,
                self.status,
            ],
        )
        super().__init__("fabric-battery-popup", "battery-popup", monitor, root)
        self.sync_profile_status()

    def on_popup_shown(self):
        self.sync_profile_status()

    def get_profile(self) -> str:
        try:
            result = subprocess.run(
                ["powerprofilesctl", "get"],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                return ""
            return (result.stdout or "").strip()
        except Exception:
            return ""

    def _mark_active_profile(self, profile: str):
        for key, btn in self.profile_buttons.items():
            ctx = btn.get_style_context()
            if key == profile:
                ctx.add_class("active")
            else:
                ctx.remove_class("active")

    def sync_profile_status(self):
        profile = self.get_profile()
        if not profile:
            self.status.set_label("Falha ao ler perfil (powerprofilesctl)")
            self._mark_active_profile("")
            return

        labels = {
            "power-saver": "Economia",
            "balanced": "Balanceado",
            "performance": "Performance",
        }
        self.status.set_label(f"Ativo: {labels.get(profile, profile)}")
        self._mark_active_profile(profile)

    def set_profile(self, profile: str):
        try:
            result = subprocess.run(
                ["powerprofilesctl", "set", profile],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                err = (result.stderr or result.stdout or "erro desconhecido").strip()
                self.status.set_label(f"Falha: {shorten(err, 64)}")
                return
        except Exception:
            self.status.set_label("Falha ao executar powerprofilesctl")
            return

        self.sync_profile_status()
