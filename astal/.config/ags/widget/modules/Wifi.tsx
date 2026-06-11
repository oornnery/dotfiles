import { Gtk } from "ags/gtk4"
import Network from "gi://AstalNetwork"
import { createBinding, createComputed, For } from "ags"
import PopButton from "../lib/PopButton"

export default function Wifi() {
  const net = Network.get_default()
  if (!net) return <box />

  const wifi = net.wifi
  if (!wifi) return <box />

  const enabled = createBinding(wifi, "enabled")
  const ssid    = createBinding(wifi, "ssid")
  const stren   = createBinding(wifi, "strength")
  const aps     = createBinding(wifi, "accessPoints")

  const glyph = createComputed((track) => {
    if (!track(enabled)) return "󰖪"
    const s = track(stren)
    if (s == null || s < 0) return "󰖩"
    if (s > 80) return "󰤨"
    if (s > 60) return "󰤥"
    if (s > 40) return "󰤢"
    if (s > 20) return "󰤟"
    return "󰤯"
  })

  const text = createComputed((track) =>
    !track(enabled) ? "off" : (track(ssid) ?? "—")
  )

  return (
    <PopButton
      cssName="wifi"
      tooltip={createComputed((track) =>
        !track(enabled)
          ? "Wi-Fi disabled"
          : track(ssid)
            ? `Connected: ${track(ssid)} (${track(stren) ?? 0}%)`
            : "Disconnected"
      )}
      glyph={glyph}
      text={text}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <box spacing={8}>
          <label label="Wi-Fi" cssClasses={["title"]} hexpand halign={Gtk.Align.START} />
          <switch
            halign={Gtk.Align.END}
            valign={Gtk.Align.CENTER}
            active={enabled}
            onStateSet={(self: Gtk.Switch, state: boolean) => {
              if (state !== wifi.enabled) wifi.enabled = state
              self.state = state
              return true
            }}
          />
          <button onClicked={() => wifi.scan()} tooltipText="Rescan">
            <label label="󰑐" />
          </button>
        </box>
        <For
          each={aps((arr: Network.AccessPoint[]) => arr.filter((a) => a.ssid && a.ssid !== "?"))}
          id={(ap: Network.AccessPoint) => ap.bssid ?? ap.ssid ?? ""}
        >
          {(ap: Network.AccessPoint) => (
            <button
              cssClasses={ssid((s: string | null) =>
                ap.ssid && ap.ssid === s ? ["ap", "active"] : ["ap"]
              )}
              onClicked={() => ap.activate(null, () => {})}
            >
              <box spacing={6}>
                <label label="󰖩" cssClasses={["glyph"]} />
                <label halign={Gtk.Align.START} hexpand label={`${ap.ssid ?? "?"}`} />
                <label cssClasses={["muted"]} label={`${ap.strength ?? 0}%`} />
              </box>
            </button>
          )}
        </For>
      </box>
    </PopButton>
  )
}
