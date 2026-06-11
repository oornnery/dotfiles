import app from "ags/gtk4/app"
import Gdk from "gi://Gdk?version=4.0"
import { createRoot } from "ags"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Sidebar from "./widget/Sidebar"

type Entry = { bar: any; sidebar: any; dispose: () => void }

// Connector name → entry. Keyed by string (eDP-1, HDMI-A-1, …) instead of by
// Gdk.Monitor reference because GTK sometimes hands out a NEW Gdk.Monitor for
// the same physical monitor across KVM transitions — keying by ref creates
// duplicate bars; keying by name dedups properly.
function connectorOf(m: Gdk.Monitor): string {
  return (m.get_connector?.() ?? (m as any).connector ?? "?") as string
}

app.start({
  css: style,
  main() {
    const windows = new Map<string, Entry>()

    const open = (m: Gdk.Monitor) => {
      const name = connectorOf(m)
      if (windows.has(name)) return

      // Bar and Sidebar in SEPARATE reactive scopes — a runtime error in
      // Sidebar (null binding, missing API) doesn't take down the Bar.
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
        console.error(`[ags] Sidebar mount failed for monitor ${name}:`, e)
      }

      windows.set(name, {
        bar: barEntry.win,
        sidebar: sidebarWin,
        dispose: () => {
          try { barEntry.dispose() } catch {}
          try { sidebarDispose?.() } catch {}
        },
      })
    }

    const close = (name: string) => {
      const entry = windows.get(name)
      if (!entry) return
      // CRITICAL: do NOT touch entry.bar / entry.sidebar here. By the time
      // items-changed fires for a monitor disconnect (KVM swap, lid close),
      // the GdkSurface backing those windows is already invalidated. ANY
      // GTK call on them — including set_visible(false), destroy(), or even
      // reading a property — triggers a C-level assertion
      // (gdk_surface_get_display: !GDK_IS_SURFACE) that segfaults the whole
      // AGS process. try/catch in JS cannot save us.
      //
      // Trade-off: the widget itself is orphaned in GTK's tree, invisible
      // (no surface to render to), and eventually GC'd. Tiny memory leak per
      // monitor disconnect — acceptable vs the entire bar crashing.
      try { entry.dispose() } catch (e) {
        console.error(`[ags] dispose error closing ${name}:`, e)
      }
      windows.delete(name)
    }

    // Initial monitors.
    app.get_monitors().forEach(open)

    // React to plug/unplug (KVM, lid, dock). Debounce 500ms so KVM swap
    // (rapid remove+add) settles before we sync.
    const display = Gdk.Display.get_default()
    if (display) {
      const monitors = display.get_monitors()
      let pending: ReturnType<typeof setTimeout> | null = null
      const sync = () => {
        try {
          const currentNames = new Set<string>()
          const n = monitors.get_n_items()
          for (let i = 0; i < n; i++) {
            const m = monitors.get_item(i) as Gdk.Monitor
            const name = connectorOf(m)
            currentNames.add(name)
            if (!windows.has(name)) open(m)
          }
          for (const name of [...windows.keys()]) {
            if (!currentNames.has(name)) close(name)
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
