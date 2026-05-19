import { Gtk } from "ags/gtk4"
import Wp from "gi://AstalWp"
import { createBinding, createComputed } from "ags"
import PopButton from "../lib/PopButton"

const GLYPHS = ["󰕿", "󰖀", "󰕾"]
const STEP = 0.05

export default function Volume() {
  const wp = Wp.get_default()
  if (!wp) return <box />
  const speaker = wp.audio.default_speaker

  const vol = createBinding(speaker, "volume")
  const muted = createBinding(speaker, "mute")

  const glyph = createComputed((track) => {
    if (track(muted)) return "󰖁"
    const v = track(vol)
    const pct = Math.round(v * 100)
    return pct >= 66 ? GLYPHS[2] : pct >= 33 ? GLYPHS[1] : GLYPHS[0]
  })
  const text = createComputed((track) => {
    if (track(muted)) return "muted"
    return `${Math.round(track(vol) * 100)}%`
  })

  const adjust = (delta: number) =>
    speaker.set_volume(Math.max(0, Math.min(1, speaker.volume + delta)))

  return (
    <PopButton
      cssName="volume"
      tooltip={text}
      glyph={glyph}
      text={text}
      setup={(self: any) => {
        const ctl = new Gtk.EventControllerScroll({
          flags: Gtk.EventControllerScrollFlags.VERTICAL,
        })
        ctl.connect("scroll", (_c: any, _dx: number, dy: number) => {
          adjust(dy < 0 ? STEP : -STEP)
          return true
        })
        self.add_controller(ctl)
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <label label="Output" cssClasses={["title"]} />
        <slider
          hexpand
          min={0} max={1} step={0.01}
          $={(self: any) => {
            self.value = speaker.volume
            speaker.connect("notify::volume", () => {
              if (Math.abs(self.value - speaker.volume) > 0.005)
                self.value = speaker.volume
            })
          }}
          onChangeValue={(self: any) => speaker.set_volume(self.value)}
        />
        <button onClicked={() => speaker.set_mute(!speaker.mute)}>
          <label label={muted((m) => m ? "Unmute" : "Mute")} />
        </button>
      </box>
    </PopButton>
  )
}
