import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import PopButton from "../lib/PopButton"

type Zone = { type: string; temp: number }
type Data = { primary: number; zones: Zone[] }

const ZERO: Data = { primary: 0, zones: [] }

export default function Temperature() {
  const data = createPoll<Data>(ZERO, 5000, async () => {
    try {
      const out = await execAsync([
        "sh", "-c",
        // For each thermal zone, print "TYPE TEMP_MILLIC"
        "for z in /sys/class/thermal/thermal_zone*; do " +
        "  [[ -r $z/type && -r $z/temp ]] || continue; " +
        "  echo \"$(cat $z/type) $(cat $z/temp)\"; " +
        "done",
      ])
      const zones: Zone[] = []
      for (const line of out.trim().split("\n")) {
        const parts = line.trim().split(/\s+/)
        if (parts.length < 2) continue
        const tempC = parseInt(parts[parts.length - 1], 10) / 1000
        const type = parts.slice(0, -1).join(" ")
        zones.push({ type, temp: tempC })
      }
      const primary = zones[0]?.temp ?? 0
      return { primary, zones }
    } catch {
      return ZERO
    }
  })

  const klass = data((d) =>
    d.primary >= 85 ? ["critical"] : d.primary >= 70 ? ["warning"] : []
  )

  return (
    <PopButton
      cssName="temperature"
      glyph="󰔏"
      text={data((d) => `${Math.round(d.primary)}°`)}
      tooltip={data((d) => `Temp ${Math.round(d.primary)}°C`)}
      setup={(self) => {
        klass.subscribe(() => {
          self.cssClasses = klass.peek()
        })
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <label label="Sensors" cssClasses={["title"]} />
        <box orientation={Gtk.Orientation.VERTICAL} spacing={2}>
          {/* render zones reactively */}
          <label
            cssClasses={["muted"]}
            label={data((d) =>
              d.zones.length === 0
                ? "no zones found"
                : d.zones
                    .map((z) => `${z.type.padEnd(18)} ${z.temp.toFixed(1)}°C`)
                    .join("\n")
            )}
            halign={Gtk.Align.START}
            useMarkup={false}
          />
        </box>
      </box>
    </PopButton>
  )
}
