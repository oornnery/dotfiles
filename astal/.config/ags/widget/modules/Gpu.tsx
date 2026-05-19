import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import PopButton from "../lib/PopButton"

type Data = { text: string; class: string; tooltip: string }

export default function Gpu() {
  const data = createPoll<Data>(
    { text: "?", class: "", tooltip: "" },
    5000,
    async (prev) => {
      try {
        const out = await execAsync(["waybar-gpu"])
        const j = JSON.parse(out)
        return { text: j.text ?? "?", class: j.class ?? "", tooltip: j.tooltip ?? "" }
      } catch {
        return prev
      }
    },
  )

  // Static GPU name — fetch once via lspci / vendor info.
  const gpuName = createPoll("GPU", 3600_000, async () => {
    try {
      const out = await execAsync(["sh", "-c", "lspci | grep -iE 'vga|3d|display' | head -1 | sed 's/.*: //' | sed 's/(rev .*)//'"])
      return out.trim() || "GPU"
    } catch { return "GPU" }
  })

  return (
    <PopButton
      cssName="gpu"
      glyph="󰢮"
      text={data((d) => d.text)}
      tooltip={data((d) => d.tooltip || `GPU ${d.text}`)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <label label="GPU" cssClasses={["title"]} />
        <label cssClasses={["muted"]} label={gpuName} wrap maxWidthChars={36} halign={Gtk.Align.START} />
        <box spacing={12}>
          <label label="Usage" cssClasses={["muted"]} halign={Gtk.Align.START} />
          <label hexpand halign={Gtk.Align.END} label={data((d) => d.text)} />
        </box>
        <label cssClasses={["muted"]} label={data((d) => d.tooltip)} wrap maxWidthChars={36} halign={Gtk.Align.START} />
      </box>
    </PopButton>
  )
}
