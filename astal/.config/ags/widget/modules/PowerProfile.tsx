import { Gtk } from "ags/gtk4"
import Pp from "gi://AstalPowerProfiles"
import { createBinding } from "ags"
import PopButton from "../lib/PopButton"

const GLYPHS: Record<string, string> = {
  "power-saver": "󰂃",
  "balanced":    "󰁹",
  "performance": "󱐋",
}

const LABELS: Record<string, string> = {
  "power-saver": "Power Saver",
  "balanced":    "Balanced",
  "performance": "Performance",
}

export default function PowerProfile() {
  const pp = Pp.get_default()
  if (!pp) return <box />

  const active = createBinding(pp, "activeProfile")

  return (
    <PopButton
      cssName="power-profile"
      tooltip={active((p) => `Profile: ${LABELS[p] ?? p}`)}
      glyph={active((p) => GLYPHS[p] ?? "󰁹")}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <label label="Power profile" cssClasses={["title"]} />
        {["power-saver", "balanced", "performance"].map((profile) => (
          <button
            cssClasses={active((a) => a === profile ? ["device", "active"] : ["device"])}
            onClicked={() => pp.set_active_profile(profile)}
          >
            <box spacing={6}>
              <label label={GLYPHS[profile]} cssClasses={["glyph"]} />
              <label halign={Gtk.Align.START} hexpand label={LABELS[profile]} />
            </box>
          </button>
        ))}
      </box>
    </PopButton>
  )
}
