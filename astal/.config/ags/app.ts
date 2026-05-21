import app from "ags/gtk4/app"
import Gdk from "gi://Gdk?version=4.0"
import { createRoot } from "ags"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Sidebar from "./widget/Sidebar"

type Entry = { bar: any; sidebar: any; dispose: () => void }

app.start({
  css: style,
  main() {
    const windows = new Map<Gdk.Monitor, Entry>()

    const open = (m: Gdk.Monitor) => {
      if (windows.has(m)) return

      // Bar and Sidebar in SEPARATE reactive scopes — a runtime error in
      // Sidebar (missing API, null binding, etc.) doesn't take down the Bar
      // on the same monitor. Each can fail independently.
      const monLabel = (m.get_connector?.() ?? m.connector ?? "?") as string

      const barEntry = createRoot<{ win: any; dispose: () => void }>((dispose) => ({
        win: Bar(m),
        dispose,
      }))

      let sidebarWin: any = null
      let sidebarDispose: (() => void) | null = null
      try {
        const sbEntry = createRoot<{ win: any; dispose: () => void }>((dispose) => ({
          win: Sidebar(m),
          dispose,
        }))
        sidebarWin = sbEntry.win
        sidebarDispose = sbEntry.dispose
      } catch (e) {
        console.error(`[ags] Sidebar mount failed for monitor ${monLabel}:`, e)
      }

      windows.set(m, {
        bar: barEntry.win,
        sidebar: sidebarWin,
        dispose: () => {
          try { barEntry.dispose() } catch {}
          try { sidebarDispose?.() } catch {}
        },
      })
    }

    const close = (m: Gdk.Monitor) => {
      const entry = windows.get(m)
      if (!entry) return
      // DON'T call .destroy() on the windows here — when GTK fires items-changed
      // on monitor disconnect (KVM switch, lid close, dock unplug), the
      // underlying GdkSurface is already invalidated. Calling .destroy() on
      // it triggers a C-level assertion (gdk_surface_get_display: !GDK_IS_SURFACE)
      // that segfaults the entire AGS process — try/catch in JS can't save us.
      // Just dispose the reactive scope; GTK garbage-collects the widget tree.
      try { entry.dispose() } catch (e) {
        console.error("[ags] dispose error during monitor close:", e)
      }
      windows.delete(m)
    }

    // Initial monitors.
    app.get_monitors().forEach(open)

    // React to plug/unplug (KVM, lid, dock).
    // Debounced: KVM switches fire remove+add in quick succession; waiting
    // 500ms before reacting lets the transient settle.
    const display = Gdk.Display.get_default()
    if (display) {
      const monitors = display.get_monitors()
      let pending: ReturnType<typeof setTimeout> | null = null
      const sync = () => {
        try {
          const current = new Set<Gdk.Monitor>()
          const n = monitors.get_n_items()
          for (let i = 0; i < n; i++) {
            const m = monitors.get_item(i) as Gdk.Monitor
            current.add(m)
            if (!windows.has(m)) open(m)
          }
          for (const m of [...windows.keys()]) {
            if (!current.has(m)) close(m)
          }
        } catch (e) {
          console.error("[ags] monitor sync failed:", e)
        }
      }
      monitors.connect("items-changed", () => {
        if (pending) clearTimeout(pending)
        pending = setTimeout(() => { pending = null; sync() }, 500)
      })
    }
  },
})
