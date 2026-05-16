# Windows VM

Windows 11 in a Docker container via [dockur/windows](https://github.com/dockur/windows).
No qemu wrangling, no virt-manager, just a `docker-compose.yml`.

## Setup

```bash
./scripts/arch/arch.sh dev/docker          # if Docker isn't installed yet
./scripts/arch/arch.sh core/windows-vm     # creates ~/.config/windows/docker-compose.yml
```

Generated compose file: [`~/.config/windows/docker-compose.yml`](../../../scripts/arch/core/windows-vm.sh).

## Tune resources

Edit the compose file before first boot:

```yaml
environment:
  VERSION: "11"
  RAM_SIZE: "4G"        # bump to 8G on a 16+ GB host
  CPU_CORES: "4"
  DISK_SIZE: "64G"      # qcow2 grows lazily
  PASSWORD: "change-me" # change before exposing the container
```

## Start

```bash
cd ~/.config/windows
docker compose up -d
```

First boot downloads the Windows ISO + does an unattended install
(~15-30 min). The container starts with `restart: unless-stopped`, so it
comes up automatically after host reboot.

## Connect

| Method     | How                                                    |
| ---------- | ------------------------------------------------------ |
| Web (VNC)  | `xdg-open http://localhost:8006`                       |
| RDP        | `xfreerdp /v:localhost /u:oornnery` (or any RDP client)|
| File share | Files dropped in `~/Windows` show up as a UNC share    |

## Stop / destroy

```bash
docker compose stop                       # graceful pause
docker compose down                       # tear down container, keep disk
docker compose down -v                    # ALSO delete the qcow2
```

## Limitations

- **No GPU passthrough** — anything GPU-heavy (gaming, CUDA) is out.
- **KVM required** — `/dev/kvm` must exist. Check with
  `[ -e /dev/kvm ] && echo ok`. AMD-V is on by default on this Vaio.
- **Networking** — bridged via Docker; LAN sees the container as the host.
  Adjust ports in the compose if you need separate IPs.
