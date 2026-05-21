import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { createBinding, createComputed, For } from "ags"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
import Bluetooth from "gi://AstalBluetooth"
import Mpris from "gi://AstalMpris"
import Battery from "gi://AstalBattery"
import Pp from "gi://AstalPowerProfiles"
import { run } from "./lib/sh"

// ─── Notification list (polls makoctl) ────────────────────────────────────

type Notif = { id: number; app: string; summary: string; body: string; urgency: string }

function parseMakoList(json: string): Notif[] {
  try {
    const obj = JSON.parse(json)
    const groups = (obj.data ?? []) as Array<Array<Record<string, { data: unknown }>>>
    const out: Notif[] = []
    for (const group of groups) {
      for (const n of group) {
        out.push({
          id: Number(n.id?.data ?? 0),
          app: String(n["app-name"]?.data ?? ""),
          summary: String(n.summary?.data ?? ""),
          body: String(n.body?.data ?? ""),
          urgency: String(n.urgency?.data ?? "normal"),
        })
      }
    }
    return out
  } catch {
    return []
  }
}

function NotificationRow({ n }: { n: Notif }) {
  return (
    <box cssName="notif-row" spacing={8}>
      <box orientation={Gtk.Orientation.VERTICAL} hexpand>
        <label
          cssClasses={["notif-summary"]}
          label={`${n.app}${n.app ? " — " : ""}${n.summary}`}
          halign={Gtk.Align.START}
          maxWidthChars={36}
          ellipsize={3}
        />
        {n.body && (
          <label
            cssClasses={["notif-body"]}
            label={n.body}
            halign={Gtk.Align.START}
            maxWidthChars={36}
            wrap
            useMarkup
          />
        )}
      </box>
      <button
        cssClasses={["notif-close"]}
        tooltipText="Dismiss"
        onClicked={() => run(["makoctl", "dismiss", "-n", String(n.id)])}
      >
        <label label="󰅖" />
      </button>
    </box>
  )
}

function Notifications() {
  const list = createPoll<Notif[]>([], 2000, async () => {
    try { return parseMakoList(await execAsync(["makoctl", "list"])) }
    catch { return [] }
  })

  const empty = list((arr) => arr.length === 0)
  const count = list((arr) => arr.length === 0 ? "" : `· ${arr.length}`)

  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssName="sidebar-notifs" spacing={6}>
      <box spacing={6}>
        <label cssClasses={["section-title"]} label="Notifications" hexpand halign={Gtk.Align.START} />
        <label cssClasses={["muted"]} label={count} />
        <button
          tooltipText="Restore last"
          onClicked={() => run(["dots-notifications", "restore"])}
        >
          <label label="󰕌" cssClasses={["glyph"]} />
        </button>
        <button
          tooltipText="Clear all"
          onClicked={() => run(["dots-notifications", "clear"])}
        >
          <label label="󰎟" cssClasses={["glyph"]} />
        </button>
      </box>
      <label
        cssClasses={["muted", "notif-empty"]}
        label="No notifications"
        visible={empty}
      />
      <scrolledwindow
        cssName="notif-scroll"
        visible={empty((e) => !e)}
        hscrollbarPolicy={Gtk.PolicyType.NEVER}
        vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
        minContentHeight={120}
        maxContentHeight={260}
      >
        <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <For each={list} id={(n: Notif) => n.id}>
            {(n: Notif) => <NotificationRow n={n} />}
          </For>
        </box>
      </scrolledwindow>
    </box>
  )
}

// ─── Quick toggles (Bluetooth / Wi-Fi / DND / Night) ──────────────────────

type ToggleProps = {
  glyph: string
  label: string
  active?: ReturnType<typeof createBinding> | null
  onClick: () => void
}

function Toggle(p: ToggleProps) {
  const cls = p.active
    ? p.active((on: boolean) => on ? ["toggle", "active"] : ["toggle"])
    : ["toggle"]
  return (
    <button cssClasses={cls as any} onClicked={p.onClick} hexpand>
      <box orientation={Gtk.Orientation.VERTICAL} spacing={2}>
        <label cssClasses={["glyph"]} label={p.glyph} />
        <label cssClasses={["toggle-label"]} label={p.label} />
      </box>
    </button>
  )
}

function QuickToggles() {
  const bt = Bluetooth.get_default()
  const net = Network.get_default()
  const wifi = net?.wifi
  const btOn = bt ? createBinding(bt, "isPowered") : null
  const wifiOn = wifi ? createBinding(wifi, "enabled") : null

  return (
    <box cssName="sidebar-toggles" spacing={6} homogeneous>
      <Toggle
        glyph="󰂯"
        label="BT"
        active={btOn}
        onClick={() => {
          const next = bt ? !bt.isPowered : true
          run(["bluetoothctl", "power", next ? "on" : "off"])
        }}
      />
      <Toggle
        glyph="󰖩"
        label="Wi-Fi"
        active={wifiOn}
        onClick={() => { if (wifi) wifi.enabled = !wifi.enabled }}
      />
      <Toggle glyph="󰪓" label="DND"   onClick={() => run(["dnd"])} />
      <Toggle glyph="󰽢" label="Night" onClick={() => run(["night-mode"])} />
      <Toggle glyph=""  label="Theme" onClick={() => run(["theme", "cycle"])} />
    </box>
  )
}

// ─── Volume + Brightness sliders (full-width, in-sidebar) ─────────────────

function VolumeSlider() {
  const wp = Wp.get_default()
  if (!wp) return <box visible={false} />
  const speaker = wp.audio.default_speaker
  const vol = createBinding(speaker, "volume")
  const muted = createBinding(speaker, "mute")
  const glyph = createComputed((track) =>
    track(muted) ? "󰖁" : track(vol) >= 0.66 ? "󰕾" : track(vol) >= 0.33 ? "󰖀" : "󰕿"
  )

  return (
    <box cssName="slider-row" spacing={8}>
      <button onClicked={() => speaker.set_mute(!speaker.mute)} cssClasses={["slider-icon"]}>
        <label label={glyph} cssClasses={["glyph"]} />
      </button>
      <slider
        hexpand
        min={0} max={1} step={0.01}
        $={(self: Gtk.Scale) => {
          self.value = speaker.volume
          speaker.connect("notify::volume", () => {
            if (Math.abs(self.value - speaker.volume) > 0.005)
              self.value = speaker.volume
          })
        }}
        onChangeValue={(self: Gtk.Scale) => speaker.set_volume(self.value)}
      />
      <label cssClasses={["slider-pct"]} label={vol((v: number) => `${Math.round(v * 100)}%`)} />
    </box>
  )
}

function BrightnessSlider() {
  const pct = createPoll<number>(0, 2000, async () => {
    try {
      const [cur, max] = await Promise.all([
        execAsync(["brightnessctl", "get"]),
        execAsync(["brightnessctl", "max"]),
      ])
      return (parseInt(cur, 10) / parseInt(max, 10)) * 100
    } catch { return 0 }
  })
  const setPct = (v: number) =>
    run(["brightnessctl", "set", `${Math.round(Math.max(5, Math.min(100, v)))}%`])

  return (
    <box cssName="slider-row" spacing={8}>
      <box cssClasses={["slider-icon"]}>
        <label label="󰃞" cssClasses={["glyph"]} />
      </box>
      <slider
        hexpand
        min={5} max={100} step={1}
        value={pct}
        onChangeValue={(self: Gtk.Scale) => setPct(self.value)}
      />
      <label cssClasses={["slider-pct"]} label={pct((p: number) => `${Math.round(p)}%`)} />
    </box>
  )
}

// ─── Player card (MPRIS) ──────────────────────────────────────────────────

function Player() {
  const mpris = Mpris.get_default()
  if (!mpris) return <box visible={false} />
  const players = createBinding(mpris, "players")
  const first = players((arr: Mpris.Player[]) => arr[0] ?? null)

  return (
    <box cssName="sidebar-player" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
      <For
        each={players((arr: Mpris.Player[]) => arr.slice(0, 1))}
        id={(p: Mpris.Player) => p.busName}
      >
        {(p: Mpris.Player) => {
          const title = createBinding(p, "title")
          const artist = createBinding(p, "artist")
          const status = createBinding(p, "playbackStatus")
          const playPauseGlyph = status((s: Mpris.PlaybackStatus) =>
            s === Mpris.PlaybackStatus.PLAYING ? "󰏤" : "󰐎"
          )
          return (
            <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
              <label cssClasses={["section-title"]} label="Now playing" halign={Gtk.Align.START} />
              <label cssClasses={["player-title"]} label={title} halign={Gtk.Align.START}
                     maxWidthChars={32} ellipsize={3} />
              <label cssClasses={["player-artist"]} label={artist} halign={Gtk.Align.START}
                     maxWidthChars={32} ellipsize={3} />
              <box spacing={8} halign={Gtk.Align.CENTER}>
                <button onClicked={() => p.previous()}><label label="󰒮" /></button>
                <button onClicked={() => p.play_pause()}><label label={playPauseGlyph} /></button>
                <button onClicked={() => p.next()}><label label="󰒭" /></button>
              </box>
            </box>
          )
        }}
      </For>
      <label
        cssClasses={["muted"]}
        label="No active player"
        visible={first((p) => p == null) as any}
      />
    </box>
  )
}

// ─── Battery panel (Omarchy-style: caps + big % + stats grid + pill profiles) ─

function fmtTime(sec: number): string {
  if (!Number.isFinite(sec) || sec <= 0) return "—"
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  return h > 0 ? `${h}h ${String(m).padStart(2, "0")}m` : `${m}m`
}

// State-based label for the battery card title (DHH-style flavor text).
function batLabel(charging: boolean, pct: number, rate: number): string {
  if (charging)         return "FEEDING VOLTS"
  if (pct < 0.15)       return "RUNNING DRY"
  if (rate > 15)        return "GUZZLING VOLTS"
  return "SIPPING VOLTS"
}

function BatteryPanel() {
  const bat = Battery.get_default()
  if (!bat || !bat.is_present) return <box visible={false} />

  const pct = createBinding(bat, "percentage")
  const charging = createBinding(bat, "charging")
  const rate = createBinding(bat, "energyRate")
  const tte = createBinding(bat, "timeToEmpty")
  const ttf = createBinding(bat, "timeToFull")

  const energyFull = bat.energyFullDesign  // Wh
  const sizeStr = energyFull > 0 ? `${Math.round(energyFull)}Wh` : "—"

  // Charge threshold: read /sys/class/power_supply/BAT0/charge_control_{start,end}_threshold.
  // Not all laptops expose these — degrade to "—".
  const threshold = createPoll("—", 60_000, async () => {
    try {
      const [s, e] = await Promise.all([
        execAsync(["cat", "/sys/class/power_supply/BAT0/charge_control_start_threshold"]),
        execAsync(["cat", "/sys/class/power_supply/BAT0/charge_control_end_threshold"]),
      ])
      const start = parseInt(s.trim(), 10)
      const end = parseInt(e.trim(), 10)
      if (Number.isNaN(start) || Number.isNaN(end)) return "—"
      return start === 0 && end === 100 ? "Off" : `${start}-${end}%`
    } catch { return "—" }
  })

  const title = createComputed((track) =>
    batLabel(track(charging), track(pct), track(rate))
  )

  const pctStr = pct((p: number) => `${Math.round(p * 100)}%`)

  const timeLeft = createComputed((track) => {
    const sec = track(charging) ? Number(track(ttf)) : Number(track(tte))
    return fmtTime(sec)
  })

  const rateRow = createComputed((track) => track(charging) ? "Charging" : "Discharging")
  const rateVal = rate((r: number) => `${Math.abs(r).toFixed(1)}W`)

  const pp = Pp.get_default()
  const active = pp ? createBinding(pp, "activeProfile") : null

  type Prof = { id: string; label: string; glyph: string }
  const profiles: Prof[] = [
    { id: "power-saver", label: "Power-saver", glyph: "" },
    { id: "balanced",    label: "Balanced",    glyph: "" },
    { id: "performance", label: "Performance", glyph: "" },
  ]

  return (
    <box cssName="battery-panel" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <box spacing={10}>
        <label cssClasses={["bat-icon"]} label={charging((c: boolean) => c ? "󰂄" : "󰁹")} />
        <label cssClasses={["bat-label"]} label={title} hexpand halign={Gtk.Align.START} />
        <label cssClasses={["bat-pct"]} label={pctStr} />
      </box>

      <levelbar
        cssClasses={["bat-bar"]}
        minValue={0}
        maxValue={1}
        value={pct}
      />

      <box cssName="bat-stats" spacing={20}>
        <box orientation={Gtk.Orientation.VERTICAL} spacing={6} hexpand>
          <box>
            <label cssClasses={["stat-key"]} label="Battery size" hexpand halign={Gtk.Align.START} />
            <label cssClasses={["stat-val"]} label={sizeStr} />
          </box>
          <box>
            <label cssClasses={["stat-key"]} label="Threshold" hexpand halign={Gtk.Align.START} />
            <label cssClasses={["stat-val"]} label={threshold} />
          </box>
        </box>
        <box orientation={Gtk.Orientation.VERTICAL} spacing={6} hexpand>
          <box>
            <label cssClasses={["stat-key"]} label="Time left" hexpand halign={Gtk.Align.START} />
            <label cssClasses={["stat-val"]} label={timeLeft} />
          </box>
          <box>
            <label cssClasses={["stat-key"]} label={rateRow} hexpand halign={Gtk.Align.START} />
            <label cssClasses={["stat-val"]} label={rateVal} />
          </box>
        </box>
      </box>

      {pp && active && (
        <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <box cssClasses={["bat-sep"]} />
          <label cssClasses={["section-title"]} label="Power profile" halign={Gtk.Align.START} />
          <box cssName="bat-profiles" spacing={8} homogeneous>
            {profiles.map((p: Prof) => (
              <button
                cssClasses={active((a: string) => a === p.id ? ["profile-btn", "active"] : ["profile-btn"])}
                onClicked={() => pp.set_active_profile(p.id)}
              >
                <box spacing={6} halign={Gtk.Align.CENTER}>
                  <label cssClasses={["glyph"]} label={p.glyph} />
                  <label label={p.label} />
                </box>
              </button>
            ))}
          </box>
        </box>
      )}
    </box>
  )
}

// ─── Theme picker (menubutton dropdown, not a row of pills) ──────────────

const THEMES = [
  "catppuccin-mocha", "catppuccin-latte", "tokyo-night",
  "gruvbox", "kanagawa", "nord", "rose-pine",
]

function ThemePicker() {
  // Poll current theme every 5s — cheap (reads ~/.local/share/dotfiles/active-theme).
  const current = createPoll<string>("catppuccin-mocha", 5_000, async () => {
    try { return (await execAsync(["theme", "get"])).trim() }
    catch { return "catppuccin-mocha" }
  })

  return (
    <box cssName="theme-picker" spacing={10}>
      <label cssClasses={["section-title"]} label="Theme" hexpand halign={Gtk.Align.START} />
      <menubutton cssClasses={["select"]}>
        <box spacing={8}>
          <label cssClasses={["select-value"]} label={current} />
          <label cssClasses={["select-chevron"]} label="󰅀" />
        </box>
        <popover cssClasses={["select-popover"]} hasArrow={false}>
          <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["select-list"]} spacing={0}>
            {THEMES.map((t: string) => (
              <button
                cssClasses={current((c: string) => c === t ? ["select-item", "active"] : ["select-item"])}
                onClicked={() => run(["theme", "set", t])}
              >
                <box spacing={8}>
                  <label
                    cssClasses={["select-check"]}
                    label={current((c: string) => c === t ? "" : " ")}
                  />
                  <label label={t} hexpand halign={Gtk.Align.START} />
                </box>
              </button>
            ))}
          </box>
        </popover>
      </menubutton>
    </box>
  )
}

// ─── Footer (date) ─────────────────────────────────────────────────────────

function Footer() {
  const time = createPoll("", 30_000, () => {
    const d = new Date()
    return d.toLocaleString(undefined, {
      weekday: "short", day: "2-digit", month: "short",
      hour: "2-digit", minute: "2-digit",
    })
  })

  return (
    <box cssName="sidebar-footer" spacing={8}>
      <label cssClasses={["muted"]} label={time} hexpand halign={Gtk.Align.START} />
    </box>
  )
}

// ─── Sidebar window ───────────────────────────────────────────────────────

export default function Sidebar(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible={false}
      name="sidebar"
      cssName="sidebar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.NORMAL}
      anchor={TOP | BOTTOM | RIGHT}
      marginTop={12}
      marginBottom={12}
      marginRight={12}
      keymode={Astal.Keymode.ON_DEMAND}
      application={app}
      $={(self: any) => {
        // Esc closes the sidebar — AstalWindow has no `key-pressed` signal,
        // so attach a real Gtk.EventControllerKey instead.
        const ctl = new Gtk.EventControllerKey()
        ctl.connect("key-pressed", (_c, keyval: number, _code: number, _mods: number) => {
          if (keyval === Gdk.KEY_Escape) {
            self.hide()
            return true
          }
          return false
        })
        self.add_controller(ctl)
      }}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        cssName="sidebar-inner"
        spacing={12}
        widthRequest={380}
      >
        <Notifications />
        <QuickToggles />
        <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <VolumeSlider />
          <BrightnessSlider />
        </box>
        <BatteryPanel />
        <Player />
        <ThemePicker />
        <Footer />
      </box>
    </window>
  )
}
