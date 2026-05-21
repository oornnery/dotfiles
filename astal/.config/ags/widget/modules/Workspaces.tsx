import { Gtk } from "ags/gtk4"
import Hyprland from "gi://AstalHyprland"
import { createBinding, For } from "ags"

export default function Workspaces() {
  const hl = Hyprland.get_default()
  if (!hl) return <box />

  const workspaces = createBinding(hl, "workspaces")
  const focused = createBinding(hl, "focusedWorkspace")

  const sorted = workspaces((arr: Hyprland.Workspace[]) =>
    [...arr].filter((w) => w.id >= 1).sort((a, b) => a.id - b.id)
  )

  return (
    <box cssName="workspaces">
      <For each={sorted} id={(ws: Hyprland.Workspace) => ws.id}>
        {(ws: Hyprland.Workspace) => (
          <button
            cssClasses={focused((f: Hyprland.Workspace | null) => f?.id === ws.id ? ["active"] : [])}
            onClicked={() => hl.dispatch("workspace", String(ws.id))}
          >
            <label label={`${ws.id}`} />
          </button>
        )}
      </For>
    </box>
  )
}
