import app from "ags/gtk4/app"
import Gdk from "gi://Gdk?version=4.0"
import { createRoot } from "ags"
import style from "./style.scss"
import Bar from "./widget/Bar"

type Entry = { win: any; dispose: () => void }

app.start({
  css: style,
  main() {
    const bars = new Map<Gdk.Monitor, Entry>()

    const open = (m: Gdk.Monitor) => {
      if (bars.has(m)) return
      // Wrap in createRoot so callbacks fired AFTER main() (e.g. from
      // monitors `items-changed`) still have a reactive tracking scope.
      const entry = createRoot<Entry>((dispose) => ({
        win: Bar(m),
        dispose,
      }))
      bars.set(m, entry)
    }

    const close = (m: Gdk.Monitor) => {
      const entry = bars.get(m)
      if (!entry) return
      try { entry.win.destroy() } catch {}
      try { entry.dispose() } catch {}
      bars.delete(m)
    }

    // Initial monitors.
    app.get_monitors().forEach(open)

    // React to plug/unplug (KVM, lid, dock).
    const display = Gdk.Display.get_default()
    if (display) {
      const monitors = display.get_monitors()
      monitors.connect("items-changed", () => {
        const current = new Set<Gdk.Monitor>()
        const n = monitors.get_n_items()
        for (let i = 0; i < n; i++) {
          const m = monitors.get_item(i) as Gdk.Monitor
          current.add(m)
          if (!bars.has(m)) open(m)
        }
        for (const m of [...bars.keys()]) {
          if (!current.has(m)) close(m)
        }
      })
    }
  },
})
