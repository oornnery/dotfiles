import { Gtk } from "ags/gtk4"
import Bluetooth from "gi://AstalBluetooth"
import { createBinding, createComputed, For } from "ags"
import PopButton from "../lib/PopButton"
import { run } from "../lib/sh"

export default function BluetoothModule() {
  const bt = Bluetooth.get_default()
  if (!bt) return <box />

  const powered = createBinding(bt, "isPowered")
  const connected = createBinding(bt, "isConnected")
  const devices = createBinding(bt, "devices")

  const glyph = createComputed((track) => {
    if (!track(powered)) return "󰂲"
    return track(connected) ? "󰂱" : "󰂯"
  })

  const text = createComputed((track) => {
    if (!track(powered)) return "OFF"
    return track(connected) ? "CONN" : "IDLE"
  })

  const tooltipText = createComputed((track) => {
    if (!track(powered)) return "Bluetooth: off"
    if (!track(connected)) return "Bluetooth: idle (no device)"
    const dev = track(devices).find((d: Bluetooth.Device) => d.connected)
    return `Bluetooth: connected — ${dev?.name ?? dev?.alias ?? "device"}`
  })

  return (
    <PopButton
      cssName="bluetooth"
      tooltip={tooltipText}
      glyph={glyph}
      text={text}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <box spacing={8}>
          <label label="Bluetooth" cssClasses={["title"]} hexpand halign={Gtk.Align.START} />
          <switch
            halign={Gtk.Align.END}
            valign={Gtk.Align.CENTER}
            active={powered}
            onStateSet={(self: Gtk.Switch, state: boolean) => {
              // bt.toggle()/bt.is_powered= no-op silently on some setups
              // (perm/rfkill). bluetoothctl always works.
              run(["bluetoothctl", "power", state ? "on" : "off"])
              self.state = state
              return true
            }}
          />
        </box>
        <For each={devices} id={(d: Bluetooth.Device) => d.address}>
          {(dev: Bluetooth.Device) => {
            const devConnected = createBinding(dev, "connected")
            return (
              <button
                cssClasses={devConnected((c: boolean) => c ? ["device", "active"] : ["device"])}
                onClicked={() => {
                  const cmd = dev.connected ? "disconnect" : "connect"
                  run(["bluetoothctl", cmd, dev.address])
                }}
              >
                <box spacing={6}>
                  <label cssClasses={["glyph"]} label={devConnected((c: boolean) => c ? "󰂱" : "󰂯")} />
                  <label hexpand halign={Gtk.Align.START} label={dev.name ?? dev.address ?? "Unknown"} />
                  <label cssClasses={["muted"]} label={devConnected((c: boolean) => c ? "connected" : "")} />
                </box>
              </button>
            )
          }}
        </For>
      </box>
    </PopButton>
  )
}
