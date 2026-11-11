# SSH

OpenSSH. Keys in `~/.ssh/`, hosts in `~/.ssh/config`; neither is in the repo.
`lazyssh` manages the hosts (`dots help lazyssh`).

## Keys

| Task | Command |
| ---- | ------- |
| New key | `ssh-keygen -t ed25519 -C "you@host"` |
| Copy it to a server | `ssh-copy-id user@host` |
| The public key, for GitHub | `cat ~/.ssh/id_ed25519.pub` (or `gh ssh-key add ~/.ssh/id_ed25519.pub`) |
| Test GitHub | `ssh -T git@github.com` |
| Permissions it wants | `chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_*` |

## The agent: type the passphrase once

```bash
systemctl --user enable --now ssh-agent.socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"   # in ~/.config/shell/local.sh
ssh-add                                                    # once per boot
```

## ~/.ssh/config

```sshconfig
Host vps
    HostName 203.0.113.10
    User ana
    IdentityFile ~/.ssh/id_ed25519

Host internal
    HostName 10.0.0.5
    ProxyJump vps            # through vps

Host *
    AddKeysToAgent yes
    ServerAliveInterval 30
```

Then `ssh vps`, `scp f vps:`, `rsync -avh dir/ vps:dir/` all use it.

## Moving files

| Task | Command |
| ---- | ------- |
| Copy to | `scp file host:/path/`, a folder: `scp -r` |
| Sync, resumable | `rsync -avh --progress dir/ host:dir/` |
| Copy from | `scp host:/path/file .` |

## Tunnels

| Task | Command |
| ---- | ------- |
| A remote port here | `ssh -L 5432:localhost:5432 vps` (the server's Postgres on your 5432) |
| A local port there | `ssh -R 8080:localhost:3000 vps` |
| A SOCKS proxy | `ssh -D 1080 vps` |
| Only the tunnel | add `-N` |

## When it fails

| Symptom | Try |
| ------- | --- |
| Which key, which config | `ssh -v host` |
| Host key changed | `ssh-keygen -R host` (only when you know why) |
| Permission denied | the permissions above; `ssh-add -l` to see the keys loaded |
