# wslc

`wslc` is the WSL container CLI. It manages images, containers, networks and volumes
from the command line, in a Docker-like way, on the WSL 2 kernel.

## Is it set up correctly?

Yes. The earlier impression that "only the Linux environment works" came from the binary
being a Windows executable: it lives at `C:\Program Files\WSL\wslc.exe` and is **not** on
the Linux `PATH`. Called by full path it works.

Checked on this machine:

- `wslc info` reports the client and the session manager (3.0.1).
- `wslc run --rm alpine:latest uname -a` pulled the image and ran; the container
  reported the same Microsoft kernel as the distro.
- The user settings file is at `%LOCALAPPDATA%\wslc\settings.yaml`
  (`wslc settings` opens it).

## Using it from zsh

`zsh/.zshrc` defines an alias when the executable exists:

```bash
alias wslc='dots wsl wslc'
```

so `wslc image list`, `wslc run ...` and the rest work from Arch. Set `WSLC_EXE` to use
a different location.

## Commands worth knowing

| Goal                           | Command                             |
| ------------------------------ | ----------------------------------- |
| Run and discard                | `wslc run --rm alpine:latest <cmd>` |
| List containers                | `wslc list`                         |
| List images                    | `wslc images`                       |
| Build                          | `wslc build -t name .`              |
| Shell into a running container | `wslc exec <id> sh`                 |
| Cleanup                        | `wslc system ...` (see `--help`)    |

## Open questions

- Compose-style multi-container files: not checked.
- Interaction with Docker Desktop (`docker-desktop` distro still exists): they are
  separate; decide whether to keep Docker Desktop once wslc covers the workflow.
- The existing `docs/docker/` material targets Docker, not wslc.
