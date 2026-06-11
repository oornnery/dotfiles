import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { createState } from "ags"

type Data = { text: string; tooltip: string }

export default function AiUsage() {
  // Probe once: if script is missing, hide the module forever.
  const [available, setAvailable] = createState(true)
  execAsync(["sh", "-c", "command -v waybar-ai-usage >/dev/null"])
    .then(() => setAvailable(true))
    .catch(() => setAvailable(false))

  const data = createPoll<Data>(
    { text: "—", tooltip: "" },
    60_000,
    async (prev) => {
      try {
        const out = await execAsync(["waybar-ai-usage"])
        const j = JSON.parse(out)
        return { text: j.text ?? "—", tooltip: j.tooltip ?? "" }
      } catch {
        return prev
      }
    },
  )

  return (
    <box
      cssName="ai-usage"
      spacing={8}
      visible={available}
      tooltipText={data((d) => d.tooltip || "AI usage")}
    >
      <label cssClasses={["glyph"]} label="" />
      <label label={data((d) => d.text)} />
    </box>
  )
}
