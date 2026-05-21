import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { run } from "../lib/sh"

type Data = { text: string; tooltip: string }

export default function Updates() {
  const data = createPoll<Data>(
    { text: "0", tooltip: "" },
    3600_000,
    async (prev) => {
      try {
        const out = await execAsync(["update", "check"])
        const j = JSON.parse(out)
        return { text: String(j.text ?? j.count ?? "0"), tooltip: j.tooltip ?? "" }
      } catch {
        return prev
      }
    },
  )

  return (
    <button
      cssName="updates"
      tooltipText={data((d) => d.tooltip || `${d.text} updates`)}
      onClicked={() => run(["alacritty", "-e", "bash", "-c", "update; read -p Done..."])}
    >
      <box spacing={8}>
        <label cssClasses={["glyph"]} label="󰚰" />
        <label label={data((d) => d.text)} />
      </box>
    </button>
  )
}
