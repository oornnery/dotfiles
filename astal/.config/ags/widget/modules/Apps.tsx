import { execAsync } from "ags/process"

export default function Apps() {
  return (
    <button
      cssName="apps"
      tooltipText="Launch app"
      onClicked={() => execAsync(["wofi", "--show", "drun"]).catch(() => {})}
    >
      <label label=" Apps" />
    </button>
  )
}
