type Props = {
  cssName?: string
  tooltip?: any
  glyph?: any
  text?: any
  children?: any
  setup?: (self: any) => void
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
