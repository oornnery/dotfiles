import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { createState } from "ags"
import PopButton from "../lib/PopButton"

type Sample = { idle: number; total: number; pct: number }
type Data = { overall: Sample; cores: Sample[] }

const ZERO_SAMPLE: Sample = { idle: 0, total: 0, pct: 0 }
const ZERO_DATA: Data = { overall: ZERO_SAMPLE, cores: [] }

const MAX_CORES = 32

function bar(pct: number, width = 10): string {
  const filled = Math.min(width, Math.max(0, Math.round((pct / 100) * width)))
  return "▮".repeat(filled) + "▯".repeat(width - filled)
}

function delta(line: string, prev: Sample): Sample {
  const nums = line.trim().split(/\s+/).slice(1).map(Number)
  const idle = (nums[3] ?? 0) + (nums[4] ?? 0)
  const total = nums.reduce((a, b) => a + b, 0)
  if (prev.total === 0) return { idle, total, pct: 0 }
  const dIdle = idle - prev.idle
  const dTotal = total - prev.total
  const pct = dTotal > 0 ? Math.max(0, 100 * (1 - dIdle / dTotal)) : prev.pct
  return { idle, total, pct }
}

export default function Cpu() {
  const cpu = createPoll<Data>(ZERO_DATA, 2000, async (prev) => {
    try {
      const out = await execAsync(["sh", "-c", "grep '^cpu' /proc/stat"])
      const lines = out.trim().split("\n")
      const overall = delta(lines[0], prev.overall)
      const cores: Sample[] = []
      for (let i = 1; i < lines.length; i++) {
        cores.push(delta(lines[i], prev.cores[i - 1] ?? ZERO_SAMPLE))
      }
      return { overall, cores }
    } catch {
      return prev
    }
  })

  const [model, setModel] = createState("CPU")
  const [cores, setCores] = createState("?")
  execAsync(["sh", "-c", "grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ *//'"])
    .then((s) => setModel(s.trim() || "CPU")).catch(() => {})
  execAsync(["sh", "-c", "nproc"])
    .then((s) => setCores(s.trim())).catch(() => {})

  const loadavg = createPoll("0.00", 5000, async () => {
    try {
      const out = await execAsync(["sh", "-c", "cut -d' ' -f1-3 /proc/loadavg"])
      return out.trim()
    } catch { return "?" }
  })

  return (
    <PopButton
      cssName="cpu"
      glyph="󰍛"
      text={cpu((d) => `${d.overall.pct.toFixed(0)}%`)}
      tooltip={cpu((d) => `CPU ${d.overall.pct.toFixed(0)}%`)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <label label="CPU" cssClasses={["title"]} />
        <label cssClasses={["muted"]} label={model} wrap maxWidthChars={36} halign={Gtk.Align.START} />
        <box spacing={12}>
          <label label={cores((c) => `${c} cores`)} halign={Gtk.Align.START} />
          <label cssClasses={["muted"]} hexpand halign={Gtk.Align.END}
            label={cpu((d) => `overall: ${d.overall.pct.toFixed(0)}%`)} />
        </box>
        <label cssClasses={["muted"]} label={loadavg((l) => `load avg: ${l}`)} halign={Gtk.Align.START} />

        <label label="Per-core" cssClasses={["title"]} />
        <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
          {Array.from({ length: MAX_CORES }).map((_, i) => {
            const exists = cpu((d) => i < d.cores.length)
            const pct = cpu((d) => d.cores[i]?.pct ?? 0)
            return (
              <box spacing={8} visible={exists}>
                <label cssClasses={["muted"]} label={`c${i.toString().padStart(2, " ")}`} />
                <label hexpand halign={Gtk.Align.START}
                  cssClasses={["cpu-bar"]}
                  label={pct((p) => bar(p))} />
                <label cssClasses={["muted"]}
                  label={pct((p) => `${p.toFixed(0).padStart(3, " ")}%`)} />
              </box>
            )
          })}
        </box>
      </box>
    </PopButton>
  )
}
