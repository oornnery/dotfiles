import { run } from "../lib/sh"

export default function Apps() {
  return (
    <button
      cssName="apps"
      tooltipText="Launch app"
      onClicked={() => run(["wofi", "--show", "drun"])}
    >
      <label label=" Apps" />
    </button>
  )
}
