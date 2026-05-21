import { Gtk } from "ags/gtk4"

// Attach a vertical scroll listener that calls `onStep` with `+1` on
// scroll-up and `-1` on scroll-down. Used by Volume / Brightness PopButtons
// for wheel-to-adjust.
export function attachVerticalScroll(
  self: Gtk.Widget,
  onStep: (dir: 1 | -1) => void,
): void {
  const ctl = new Gtk.EventControllerScroll({
    flags: Gtk.EventControllerScrollFlags.VERTICAL,
  })
  ctl.connect("scroll", (_c, _dx: number, dy: number) => {
    onStep(dy < 0 ? 1 : -1)
    return true
  })
  self.add_controller(ctl)
}
