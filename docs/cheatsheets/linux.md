# Linux

The everyday commands, with the tools installed here; (net-tools) ones come with
`dots install net-tools`. Aliases in `dots help aliases`.

## Files

| Task | Command |
| ---- | ------- |
| List, with git state | `ll` (eza), `lt` as a tree |
| Find by name | `fd name`, `fd -e md`, `fd -H` hidden too |
| Find by content | `rg text`, `rg -i text -t py`, `rg -l text` only names |
| What takes the space | `dust`, `dust -d 2 ~` |
| Free space | `duf` |
| Read | `b file` (bat), `glow file.md`, `fx file.json`, `tw file.csv`, `dots preview file` |
| Replace in files | `sd 'old' 'new' file`, or `rg -l old \| xargs sd old new` |
| Copy a folder, resumable | `rsync -avh --progress src/ dest/` |
| Archives | `7z a x.7z dir`, `7z x file.{7z,zip,rar}`, `tar -xf x.tar.gz`, `tar -czf x.tar.gz dir` |
| Link | `ln -s target name` |
| Which command, which package | `type cmd`, `pkgfile cmd` |

## Permissions

| Task | Command |
| ---- | ------- |
| See them | `ll` or `stat file` |
| Executable | `chmod +x script` |
| Only me | `chmod 600 file`, `chmod 700 dir` |
| Owner | `sudo chown -R "$USER": dir` |
| My groups | `id`; a new group counts after logging in again |

## Processes

| Task | Command |
| ---- | ------- |
| See them | `btop`, or `procs`, `procs name` |
| Stop one | `kill PID`; stuck: `kill -9 PID`; by name: `pkill name` |
| What uses a port | `ss -tulpn \| rg :8080` |
| What holds a file | `fuser -v file` |
| Run in the background | `cmd &`, `jobs`, `fg`; keep after closing: `nohup cmd &` |
| Time it | `time cmd`, compare: `hyperfine 'cmd a' 'cmd b'` |

## Network

| Task | Command |
| ---- | ------- |
| Addresses | `ip a` (`ip` is colored) |
| DNS (net-tools) | `doggo example.com`, `doggo MX example.com` |
| Path and loss | `trip example.com`; `mtr example.com` (net-tools) |
| Ping with a graph (net-tools) | `gping example.com` |
| HTTP | `xh example.com`, `xh POST api/x name=a`, or `posting` |
| Download | `wget url`, `curl -LO url` |
| Who owns a domain (net-tools) | `whois example.com` |
| Ports of a host (net-tools) | `nmap -F host` |

## Text

| Task | Command |
| ---- | ------- |
| JSON | `jq '.items[].name' f.json`, `curl ... \| jq` |
| YAML, TOML | `yq '.key' f.yaml` |
| HTML, XML | `htmlq 'a' --attribute href`, `xmlstarlet sel -t -v '//x' f.xml` |
| Count lines | `wc -l f`, code: `tokei` |
| Sort and count | `sort \| uniq -c \| sort -rn` |
| Columns | `column -t`, `cut -d, -f2` |
| Compare | `diff -u a b`, `git diff --no-index a b` (delta colors it) |

## System

| Task | Command |
| ---- | ------- |
| Summary | `fastfetch` |
| Kernel, distro | `uname -r`, `cat /etc/os-release` |
| Memory | `free -h` |
| Services and logs | `systemctl-tui`, `lazyjournal` (`dots help systemctl`) |
| Packages | `dots pkg`, `dots update` (`dots help pacman`) |
| Security issues | `arch-audit` |
| What is pending here | `dots status` |

## Man pages and examples

| Task | Command |
| ---- | ------- |
| Short examples | `tldr tar` |
| The manual | `man tar`, in Portuguese: `man -L pt_BR ls` |
| Search manuals | `Alt /`, then the `linux` mode |
| Built-in help | `cmd --help \| b -l help` |
