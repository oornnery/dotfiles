import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import PopButton from "../lib/PopButton"

export default function Calendar() {
  const date = createPoll("", 30_000, "date +'%a %b %d  %H:%M'")
  return (
    <PopButton cssName="calendar" text={date} tooltip="Calendar">
      <Gtk.Calendar />
    </PopButton>
  )
}
