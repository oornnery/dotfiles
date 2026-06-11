import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"
import { createState } from "ags"
import { execAsync } from "ags/process"
import { run } from "../lib/sh"

export default function KbLayout() {
  const hl = Hyprland.get_default()
  const [layout, setLayout] = createState("us")

  execAsync(["sh", "-c", "hyprctl -j getoption input:kb_layout | jq -r '.str' | cut -c1-2"])
    .then((s) => setLayout(s.trim() || "us"))
    .catch(() => {})

  hl?.connect("keyboard-layout", (_self, _kb: string, variant: string) => {
    setLayout((variant || "us").slice(0, 2).toLowerCase())
  })

  return (
    <button
      cssName="kb-layout"
      tooltipText={layout((l) => `Layout: ${l.toUpperCase()}`)}
      onClicked={() => run(["hyprctl", "switchxkblayout", "all", "next"])}
    >
      <box spacing={8}>
        <label cssClasses={["glyph"]} label="󰌌" />
        <label label={layout((l) => l.toUpperCase())} />
      </box>
    </button>
  )
}
