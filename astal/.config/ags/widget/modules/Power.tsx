import { execAsync } from "ags/process"

export default function Power() {
  return (
    <button
      cssName="power"
      tooltipText="Power menu"
      onClicked={() => execAsync(["power-menu"]).catch(() => {})}
    >
      <image iconName="system-shutdown-symbolic" />
    </button>
  )
}
