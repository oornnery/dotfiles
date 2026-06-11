import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"

import Apps         from "./modules/Apps"
import Workspaces   from "./modules/Workspaces"
import Calendar     from "./modules/Calendar"
import AiUsage      from "./modules/AiUsage"
import Music        from "./modules/Music"
import Updates      from "./modules/Updates"
import Cpu          from "./modules/Cpu"
import Memory       from "./modules/Memory"
import Gpu          from "./modules/Gpu"
import Temperature  from "./modules/Temperature"
import Wifi         from "./modules/Wifi"
import Bluetooth    from "./modules/Bluetooth"
import Volume       from "./modules/Volume"
import Brightness   from "./modules/Brightness"
import Battery      from "./modules/Battery"
import KbLayout     from "./modules/KbLayout"
import Power        from "./modules/Power"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  // Replaces waybar at top: TOP + EXCLUSIVE reserves the space so windows
  // don't overlap. Margins make the bar float pill-style.
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name="bar"
      cssName="bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      marginTop={8}
      marginLeft={8}
      marginRight={8}
      application={app}
    >
      <centerbox>
        <box $type="start" spacing={3}>
          <Apps />
          <Workspaces />
          <Music />
        </box>

        <box $type="center">
          <Calendar />
        </box>

        <box $type="end" spacing={3}>
          <AiUsage />
          <Updates />
          <Cpu />
          <Memory />
          <Gpu />
          <Temperature />
          <Wifi />
          <Bluetooth />
          <Volume />
          <Brightness />
          <Battery />
          <KbLayout />
          <Power />
        </box>
      </centerbox>
    </window>
  )
}
