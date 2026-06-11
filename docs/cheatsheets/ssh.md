# SSH Cheatsheet

OpenSSH client. Config in `~/.ssh/config`, keys in `~/.ssh/`.

## Connect

| Command                          | What it does                         |
| -------------------------------- | ------------------------------------ |
| `ssh user@host`                  | Connect with username                |
| `ssh host`                       | Use config alias (see below)         |
| `ssh -p 2222 host`               | Custom port                          |
| `ssh -i ~/.ssh/key host`         | Specific key                         |
| `ssh -A host`                    | Forward your agent (chained hops)    |
| `ssh -J jump host`               | Jump via `jump` host (ProxyJump)     |
| `ssh -v host`                    | Verbose (debug auth)                 |
| `ssh -vvv host`                  | Very verbose                         |

## ~/.ssh/config example

```ssh-config
# Default options for ALL hosts
Host *
    ServerAliveInterval 60
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519

# A specific server
Host vps
    HostName 1.2.3.4
    User fabio
    Port 2222
    IdentityFile ~/.ssh/vps_ed25519

# Jump host shortcut
Host internal-*
    User fabio
    ProxyJump bastion
```

Then: `ssh vps`, `ssh internal-db`, etc.

## Keys

| Command                                    | What it does                |
| ------------------------------------------ | --------------------------- |
| `ssh-keygen -t ed25519 -C "fabio@host"`    | Generate ed25519 key        |
| `ssh-keygen -t ed25519 -f ~/.ssh/vps_ed25519` | New key in specific path |
| `ssh-keygen -p -f ~/.ssh/key`              | Change passphrase           |
| `ssh-keygen -y -f ~/.ssh/key`              | Print public key            |
| `ssh-keygen -F host`                       | Find host in known_hosts    |
| `ssh-keygen -R host`                       | Remove host from known_hosts (after re-install) |
| `ssh-copy-id host`                         | Install your pubkey on host |

## ssh-agent

| Command                          | What it does                       |
| -------------------------------- | ---------------------------------- |
| `eval "$(ssh-agent -s)"`         | Start agent in current shell       |
| `ssh-add ~/.ssh/key`             | Add key to running agent           |
| `ssh-add -l`                     | List loaded keys                   |
| `ssh-add -d ~/.ssh/key`          | Remove specific key                |
| `ssh-add -D`                     | Remove all keys                    |
| `ssh-add -t 1h ~/.ssh/key`       | Add key with timeout               |

> With `AddKeysToAgent yes` in `~/.ssh/config`, keys auto-load on first use.

## File transfer

| Command                                    | What it does                 |
| ------------------------------------------ | ---------------------------- |
| `scp file host:/path/`                     | Copy local → remote          |
| `scp host:/path/file .`                    | Copy remote → local          |
| `scp -r dir/ host:/path/`                  | Recursive                    |
| `rsync -avP src/ host:/dst/`               | Faster, resumable, deltas    |
| `rsync -avP host:/src/ dst/`               | Pull, same flags             |
| `rsync -avP --delete src/ host:/dst/`      | Mirror (deletes on dst)      |
| `sftp host`                                | Interactive transfer session |

> `rsync` is almost always preferred — partial transfers, progress, smart deltas.

## Port forwarding

| Command                                    | What it does                                |
| ------------------------------------------ | ------------------------------------------- |
| `ssh -L 8080:localhost:80 host`            | Local → remote (open `localhost:8080` here) |
| `ssh -R 9000:localhost:3000 host`          | Remote → local (host exposes your `:3000`)  |
| `ssh -D 1080 host`                         | SOCKS proxy on local `:1080`                |
| `ssh -N -L 8080:db:5432 host`              | `-N` = no shell, just forward               |

## Useful flags

| Flag                | Effect                                |
| ------------------- | ------------------------------------- |
| `-N`                | No remote command (just forward/keep) |
| `-f`                | Fork to background after auth         |
| `-T`                | Disable PTY (good for non-interactive)|
| `-t`                | Force PTY (for nested `ssh` chains)   |
| `-o "Opt=val"`      | One-shot config option                |
| `-C`                | Compression (only slow links)         |

## Common recipes

```bash
# Tunnel local Postgres to remote db
ssh -N -L 5433:db.internal:5432 bastion

# Mount remote dir as local FS (sshfs)
sshfs host:/remote/dir ~/mnt/host

# Run a remote command and exit
ssh host 'docker ps'

# Run a multi-line script remotely
ssh host bash <<'EOF'
cd /var/log
ls -lh | head
EOF

# Tail a remote log live
ssh host 'tail -f /var/log/app.log'
```

## Tips

| Tip                                              | Why it helps                          |
| ------------------------------------------------ | ------------------------------------- |
| `~/.ssh/config` aliases → just `ssh vps`         | No memorizing IPs/ports               |
| `AddKeysToAgent yes` + ed25519                   | Passphrase prompt once per session    |
| Use `ProxyJump` for bastions                     | One command, no nested ssh shells     |
| `rsync` over `scp`                               | Resumable, faster on re-runs          |
| Hosts get rebuilt? `ssh-keygen -R host`          | Avoid "host key changed" warnings     |
| Set `ServerAliveInterval 60`                     | Keeps long sessions alive             |
