import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import PopButton from "../lib/PopButton"

const STEP = 5

export default function Brightness() {
  const pct = createPoll(0, 2000, async () => {
    try {
      const [cur, max] = await Promise.all([
        execAsync(["brightnessctl", "get"]),
        execAsync(["brightnessctl", "max"]),
      ])
      return (parseInt(cur, 10) / parseInt(max, 10)) * 100
    } catch {
      return 0
    }
  })

  const set = (v: number) =>
    execAsync(["brightnessctl", "set", `${Math.round(Math.max(5, Math.min(100, v)))}%`]).catch(() => {})

  return (
    <PopButton
      cssName="brightness"
      tooltip={pct((p) => `Brightness ${Math.round(p)}%`)}
      glyph="󰃟"
      text={pct((p) => `${Math.round(p)}%`)}
      setup={(self: any) => {
        const ctl = new Gtk.EventControllerScroll({
          flags: Gtk.EventControllerScrollFlags.VERTICAL,
        })
        ctl.connect("scroll", (_c: any, _dx: number, dy: number) => {
          set(pct.peek() + (dy < 0 ? STEP : -STEP))
          return true
        })
        self.add_controller(ctl)
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <label label="Screen" cssClasses={["title"]} />
        <slider
          hexpand
          min={5} max={100} step={1}
          value={pct}
          onChangeValue={(self: any) => { set(self.value) }}
        />
      </box>
    </PopButton>
  )
}
