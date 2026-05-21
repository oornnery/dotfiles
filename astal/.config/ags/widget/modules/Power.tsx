import { run } from "../lib/sh"

export default function Power() {
  return (
    <button
      cssName="power"
      tooltipText="Power menu"
      onClicked={() => run(["power-menu"])}
    >
      <image iconName="system-shutdown-symbolic" />
    </button>
  )
}
