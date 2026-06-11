import type { Gtk } from "ags/gtk4"
import type { Accessor } from "ags"

type StringProp = string | Accessor<string>

type Props = {
  cssName?: string
  tooltip?: StringProp
  glyph?: StringProp
  text?: StringProp
  children?: JSX.Element | JSX.Element[]
  setup?: (self: Gtk.MenuButton) => void
}

export default function PopButton(p: Props) {
  return (
    <menubutton cssName={p.cssName} tooltipText={p.tooltip} $={p.setup}>
      <box spacing={8}>
        {p.glyph !== undefined && <label cssClasses={["glyph"]} label={p.glyph} />}
        {p.text !== undefined && <label label={p.text} />}
      </box>
      <popover hasArrow>{p.children}</popover>
    </menubutton>
  )
}
