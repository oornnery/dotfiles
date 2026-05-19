import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"
import { createBinding, For } from "ags"

export default function Workspaces() {
  const hl = Hyprland.get_default()
  if (!hl) return <box />

  const workspaces = createBinding(hl, "workspaces")
  const focused = createBinding(hl, "focusedWorkspace")

  const sorted = workspaces((arr) =>
    [...arr].filter((w: any) => w.id >= 1).sort((a: any, b: any) => a.id - b.id)
  )

  return (
    <box cssName="workspaces">
      <For each={sorted}>
        {(ws: any) => (
          <button
            cssClasses={focused((f: any) => f?.id === ws.id ? ["active"] : [])}
            onClicked={() => ws.focus()}
          >
            <label label={`${ws.id}`} />
          </button>
        )}
      </For>
    </box>
  )
}
