# system

Files installed outside `$HOME`, as root, by the setups of `dots install`. Stow does
not link these: each setup copies them, so a change here needs that setup again.

| Folder | Setup | Installs |
| ------ | ----- | -------- |
| `wsl-automount/` | `dots install automount` | `/usr/local/bin/dots-automount` and its systemd service |
