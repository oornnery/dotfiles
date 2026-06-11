import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import PopButton from "../lib/PopButton"

type Mem = {
  totalGB: number
  usedGB: number
  availGB: number
  pct: number
  swapTotalGB: number
  swapUsedGB: number
}

const ZERO: Mem = {
  totalGB: 0, usedGB: 0, availGB: 0, pct: 0,
  swapTotalGB: 0, swapUsedGB: 0,
}

export default function Memory() {
  const mem = createPoll<Mem>(ZERO, 5000, async () => {
    try {
      // /proc/meminfo values in kB
      const out = await execAsync(["sh", "-c", "cat /proc/meminfo"])
      const kv: Record<string, number> = {}
      for (const line of out.split("\n")) {
        const m = line.match(/^(\w+):\s+(\d+)/)
        if (m) kv[m[1]] = parseInt(m[2], 10)
      }
      const total = kv["MemTotal"] || 0
      const avail = kv["MemAvailable"] || 0
      const used = total - avail
      const swapTotal = kv["SwapTotal"] || 0
      const swapFree = kv["SwapFree"] || 0
      const swapUsed = swapTotal - swapFree
      return {
        totalGB: total / 1024 / 1024,
        usedGB: used / 1024 / 1024,
        availGB: avail / 1024 / 1024,
        pct: total > 0 ? (used * 100) / total : 0,
        swapTotalGB: swapTotal / 1024 / 1024,
        swapUsedGB: swapUsed / 1024 / 1024,
      }
    } catch {
      return ZERO
    }
  })

  const fmt = (g: number) => g.toFixed(1) + " GiB"

  return (
    <PopButton
      cssName="memory"
      glyph="󰾆"
      text={mem((m) => `${m.pct.toFixed(0)}%`)}
      tooltip={mem((m) => `RAM ${m.pct.toFixed(0)}% — ${fmt(m.usedGB)} / ${fmt(m.totalGB)}`)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <label label="Memory" cssClasses={["title"]} />
        <box spacing={12}>
          <label label="Used" cssClasses={["muted"]} halign={Gtk.Align.START} />
          <label hexpand halign={Gtk.Align.END} label={mem((m) => `${fmt(m.usedGB)} / ${fmt(m.totalGB)} (${m.pct.toFixed(0)}%)`)} />
        </box>
        <box spacing={12}>
          <label label="Free" cssClasses={["muted"]} halign={Gtk.Align.START} />
          <label hexpand halign={Gtk.Align.END} label={mem((m) => fmt(m.availGB))} />
        </box>
        <label label="Swap" cssClasses={["title"]} />
        <box spacing={12}>
          <label label="Used" cssClasses={["muted"]} halign={Gtk.Align.START} />
          <label hexpand halign={Gtk.Align.END} label={mem((m) =>
            m.swapTotalGB > 0
              ? `${fmt(m.swapUsedGB)} / ${fmt(m.swapTotalGB)}`
              : "disabled"
          )} />
        </box>
      </box>
    </PopButton>
  )
}
