import { Gtk } from "ags/gtk4"
import Mpris from "gi://AstalMpris"
import { createBinding, createComputed, For } from "ags"
import { createPoll } from "ags/time"

const PLAYER_GLYPHS: Record<string, string> = {
  spotify:  "",
  mpv:      "󰎁",
  firefox:  "󰈹",
  chromium: "",
}

function pickGlyph(identity: string): string {
  const key = (identity || "").toLowerCase()
  for (const k of Object.keys(PLAYER_GLYPHS)) {
    if (key.includes(k)) return PLAYER_GLYPHS[k]
  }
  return "󰎈"
}

function fmt(us: number): string {
  const total = Math.max(0, Math.floor(us / 1_000_000))
  const m = Math.floor(total / 60)
  const s = total % 60
  return `${m}:${s.toString().padStart(2, "0")}`
}

export default function Music() {
  const mpris = Mpris.get_default()
  if (!mpris) return <box visible={false} />

  const players = createBinding(mpris, "players")
  const visible = players((arr) => arr.length > 0)

  return (
    <box visible={visible}>
      <For
        each={players((arr: Mpris.Player[]) => arr.slice(0, 1))}
        id={(p: Mpris.Player) => p.busName}
      >
        {(player: Mpris.Player) => {
          const title = createBinding(player, "title")
          const status = createBinding(player, "playbackStatus")
          // Mpris players don't emit notify::position during natural playback,
          // so poll it. Length only changes on track-change, so binding works.
          const position = createPoll(0, 1000, () => player.position)
          const length = createBinding(player, "length")

          const titleShort = title((t) => {
            const s = (t ?? "").trim() || "—"
            return s.length > 10 ? s.slice(0, 10) + "…" : s
          })

          const time = createComputed((track) => {
            const p = track(position)
            const l = track(length)
            if (l <= 0) return ""
            return `[${fmt(p)}/${fmt(l)}]`
          })

          const playPauseGlyph = status((s) =>
            s === Mpris.PlaybackStatus.PLAYING ? "󰏤" : "󰐎"
          )

          const playerGlyph = pickGlyph(player.identity ?? player.busName ?? "")

          return (
            <box cssName="music" spacing={6}>
              <button onClicked={() => player.previous()} tooltipText="Previous">
                <label label="󰒮" />
              </button>
              <button onClicked={() => player.play_pause()} tooltipText="Play/Pause">
                <label label={playPauseGlyph} />
              </button>
              <button onClicked={() => player.next()} tooltipText="Next">
                <label label="󰒭" />
              </button>
              <label cssClasses={["glyph"]} label={playerGlyph} />
              <label label={titleShort} />
              <label cssClasses={["muted"]} label={time} />
            </box>
          )
        }}
      </For>
    </box>
  )
}
