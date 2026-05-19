import { Gtk } from "ags/gtk4"
import Battery from "gi://AstalBattery"
import Pp from "gi://AstalPowerProfiles"
import { createBinding, createComputed } from "ags"
import PopButton from "../lib/PopButton"

const BAT_ICONS = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

const PROFILE_GLYPHS: Record<string, string> = {
  "power-saver": "󰂃",
  "balanced":    "󰁹",
  "performance": "󱐋",
}
const PROFILE_LABELS: Record<string, string> = {
  "power-saver": "Power Saver",
  "balanced":    "Balanced",
  "performance": "Performance",
}

export default function BatteryModule() {
  const bat = Battery.get_default()
  if (!bat || !bat.is_present) return <box visible={false} />

  const pct = createBinding(bat, "percentage")
  const charging = createBinding(bat, "charging")

  const glyph = createComputed((track) => {
    if (track(charging)) return "󰂄"
    const idx = Math.max(0, Math.min(9, Math.floor(track(pct) * 10)))
    return BAT_ICONS[idx]
  })

  const text = pct((p) => `${Math.round(p * 100)}%`)

  const klass = pct((p) => {
    if (p < 0.15) return ["critical"]
    if (p < 0.30) return ["warning"]
    return []
  })

  const tooltip = createComputed((track) => {
    const p = Math.round(track(pct) * 100)
    return track(charging) ? `Charging — ${p}%` : `Battery ${p}%`
  })

  const pp = Pp.get_default()
  const active = pp ? createBinding(pp, "activeProfile") : null

  const profiles = ["power-saver", "balanced", "performance"]

  return (
    <PopButton
      cssName="battery"
      glyph={glyph}
      text={text}
      tooltip={tooltip}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <label label="Battery" cssClasses={["title"]} />
        <label cssClasses={["muted"]} label={tooltip} />
        {pp && active ? (
          <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
            <label label="Power profile" cssClasses={["title"]} />
            {profiles.map((profile) => (
              <button
                cssClasses={active((a: any) => a === profile ? ["device", "active"] : ["device"])}
                onClicked={() => pp.set_active_profile(profile)}
              >
                <box spacing={6}>
                  <label cssClasses={["glyph"]} label={PROFILE_GLYPHS[profile]} />
                  <label halign={Gtk.Align.START} hexpand label={PROFILE_LABELS[profile]} />
                </box>
              </button>
            ))}
          </box>
        ) : <box visible={false} />}
      </box>
    </PopButton>
  )
}
