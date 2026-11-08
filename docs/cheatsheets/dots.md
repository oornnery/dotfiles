# dots

Run `dots` alone for a menu, or press Tab after `dots`. In a checklist, `x` marks,
`Enter` confirms and `Esc` cancels. Each command takes `-h` for its help.

Keys: `Alt /` searches all of it with fzf, `Alt ?` opens these pages (`dots help keys`
lists every key). A new machine starts with `./bootstrap`.

The tables below come from the header of each command (`docs/generate`). The
`desktop` commands exist where the `hyprland` package is linked.

<!-- dots:actions -->
**machine**

| Command | What it does |
| ------- | ------------ |
| `dots apply` | Make this machine match its file in machines/: links, tools, packages |
| `dots apply run` | Make this machine match the repo |
| `dots apply -n` | Show what it would do |
| `dots doctor` | What is broken: links, tools, scripts, PATH, Node, language servers |
| `dots migrate` | Run the one-time changes this machine has not run yet |
| `dots migrate run` | Run the pending migrations |
| `dots migrate list` | Every migration, * = ran here |
| `dots migrate new` | Write the next migration |
| `dots status` | What is pending: commits, links, migrations, packages, Windows |
| `dots status -f` | Also ask the remote and the repos (slower) |

**config**

| Command | What it does |
| ------- | ------------ |
| `dots edit` | Pick a file in ~/dotfiles and open it in the editor |
| `dots link` | Keep configs in ~/dotfiles and link them into $HOME |
| `dots link pick` | Choose what is linked here |
| `dots link add` | Add a config to the repo |
| `dots link list` | List the packages |
| `dots link sync` | Link every package of this machine |
| `dots link sync -n` | Show what sync would do |
| `dots theme` | Switch the color theme: terminal, TUIs, prompt and editors |
| `dots theme set` | Pick a theme, previewing it live |
| `dots theme list` | Themes and their colors |
| `dots theme get` | The active theme |
| `dots theme apply` | Write the active theme again |

**packages**

| Command | What it does |
| ------- | ------------ |
| `dots install` | Set up a tool: its packages, config links, permissions and services |
| `dots pkg` | Map installed packages to ~/dotfiles/packages and reinstall them |
| `dots pkg status` | Installed and saved, per manager |
| `dots pkg list` | What is installed now |
| `dots pkg add` | Install packages and save the list |
| `dots pkg remove` | Remove packages and save the list |
| `dots pkg save` | Write the package lists |
| `dots pkg diff` | Compare installed and saved |
| `dots pkg restore` | Install what is saved but missing |
| `dots try` | Try packages in a throwaway container, gone when you leave |
| `dots update` | Pending updates for system and dev tools; upgrade them all |
| `dots update run` | Upgrade everything |
| `dots update list` | What has updates |
| `dots update refresh` | Scan for updates now |

**use**

| Command | What it does |
| ------- | ------------ |
| `dots help` | Cheatsheets, plus your live aliases, functions and snippets |
| `dots palette` | Search TUIs, commands, keys, help, man pages and snippets, with a preview |
| `dots palette tui` | Only the TUIs |
| `dots palette dots` | Only dots commands |
| `dots palette keys` | Only keyboard shortcuts |
| `dots palette help` | Only help pages |
| `dots palette run` | Any command |
| `dots palette linux` | Man pages |
| `dots palette pet` | Pet snippets |
| `dots pane` | Run a command in a new Zellij pane, or right here outside Zellij |
| `dots tui` | Pick a TUI and open it |

**platform**

| Command | What it does |
| ------- | ------------ |
| `dots wsl` | WSL report (safe to paste) and wslc passthrough |
| `dots wsl info` | WSL report, safe to paste |
| `dots wsl windows` | Copy configs to Windows |
| `dots wsl windows -n` | Compare configs with Windows |
| `dots wsl windows pull` | Bring back configs changed on Windows |
| `dots wsl windows export` | Save the winget package list |
| `dots wsl windows install` | Install groups of packages (core, dev, game...) |
| `dots wsl windows install -n` | What each group would install |
| `dots wsl windows restore` | Install every saved winget package |
| `dots wsl windows settings` | Apply the Windows settings |
| `dots wsl windows settings -n` | Test the Windows settings |
| `dots wsl wslc` | Run wslc.exe |

**desktop**

| Command | What it does |
| ------- | ------------ |
| `dots capture` | Screenshots, screen recording, OCR and color picker |
| `dots capture screenshot region` | Pick an area and annotate it |
| `dots capture screenshot full` | The whole screen |
| `dots capture screenshot window` | The active window |
| `dots capture record` | Start or stop recording |
| `dots capture record region` | Record an area |
| `dots capture record stop` | Stop recording |
| `dots capture ocr` | Copy the text in an area |
| `dots capture color` | Pick a color from the screen |
| `dots display` | Brightness, night light, zoom, wallpaper and screensaver |
| `dots display night` | Toggle the night light |
| `dots display magnify` | Toggle the screen zoom |
| `dots display wallpaper next` | Next wallpaper |
| `dots display wallpaper random` | Random wallpaper |
| `dots display wallpaper list` | List wallpapers |
| `dots display screensaver` | Start the screensaver |
| `dots hypr` | Hyprland: look, layout, monitors, gamemode, keybinds and reload |
| `dots hypr gaps` | Toggle gaps and borders |
| `dots hypr layout` | Switch dwindle and master |
| `dots hypr transparency` | Toggle transparency |
| `dots hypr corners sharp` | Square corners |
| `dots hypr corners round` | Round corners |
| `dots hypr gamemode` | Toggle gaming mode |
| `dots hypr mirror` | Toggle the monitor mirror |
| `dots hypr scratch` | Toggle the scratch terminal |
| `dots hypr keys` | Search the keybinds |
| `dots hypr reload` | Reload Hyprland, bar and notifications |
| `dots hypr exit` | Leave Hyprland |
| `dots notifications` | Notification history, do not disturb, reminders and info cards |
| `dots notifications pick` | Act on a notification |
| `dots notifications restore` | Bring back the last one |
| `dots notifications clear` | Dismiss all |
| `dots notifications dnd` | Toggle do not disturb |
| `dots notifications reminders` | Pending reminders |
| `dots notifications info date` | Date and week |
| `dots notifications info weather` | Current weather |
| `dots notifications info battery` | Battery state |
| `dots notifications info network` | IP addresses |
| `dots notifications info system` | Uptime, load, memory, disk |
| `dots system` | Power menu and profiles, volume, GPU usage and hibernation |
| `dots system power` | Lock, suspend, reboot, shut down |
| `dots system profile` | The power profile |
| `dots system profile cycle` | Next power profile |
| `dots system volume mute` | Toggle mute |
| `dots system volume mic-mute` | Toggle the microphone |
| `dots system hibernation status` | Is hibernation ready |
| `dots webapp` | Web apps as windows (firefoxpwa) |
| `dots webapp list` | Installed web apps |
| `dots webapp remove` | Remove a web app |
<!-- /dots:actions -->
