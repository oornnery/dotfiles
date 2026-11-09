# wslc

The WSL container CLI: images, containers, networks and volumes, like Docker, on
the WSL kernel. It is a Windows program (`C:\Program Files\WSL\wslc.exe`), outside
the Linux `PATH`; the `wslc` alias runs it through `dots wsl wslc`.

## Commands

| Command | What it does |
| ------- | ------------ |
| `wslc run --rm alpine:latest uname -a` | Run and throw away |
| `wslc run -it debian:stable sh` | A shell in a new container (`-i` input, `-t` terminal) |
| `wslc list` | Containers |
| `wslc images` | Images |
| `wslc pull image` | Download an image |
| `wslc build -t name .` | Build from a Dockerfile |
| `wslc exec -it <id> sh` | A shell in a running container |
| `wslc logs <id>` | Its output |
| `wslc stats` | CPU and memory of each one |
| `wslc remove <id>` / `wslc rmi <image>` | Remove a container, an image |
| `wslc info` | Versions and the session |
| `wslc settings` | Its settings file, in the Windows editor |

`wslc <command> --help` has the options of each. Docker (`docker`, `lazydocker`) is
separate: what one creates the other does not see.

## Try a package instead

To try a tool without installing it, `dots try <package>` is shorter: a throwaway
container with the package, your folder at `/work`, gone on exit (`dots help dots`).
