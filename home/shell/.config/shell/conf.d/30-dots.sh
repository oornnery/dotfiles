# Integrations with the dots CLI. Each line is a no-op without it.

# sudo with the gum password prompt. `function` keeps the sudo alias from
# expanding here; the alias still expands in front of it (sudo ll).
if [ -x "$HOME/.local/lib/dots/askpass" ]; then
    export SUDO_ASKPASS="$HOME/.local/lib/dots/askpass"
    function sudo { command sudo -A "$@"; }
fi

# Reset PAM faillock after a cancelled sudo prompt locked you out.
sudo-unlock() { sudo faillock --user "${1:-$USER}" --reset; }

# wslc (WSL containers) lives on the Windows side, outside the Linux PATH.
[ -x "/mnt/c/Program Files/WSL/wslc.exe" ] && alias wslc='dots wsl wslc'

# The count of dots status in the prompt: refreshed in the background when it is
# 30 minutes old, so a new shell never waits for it.
if command -v dots >/dev/null 2>&1 &&
   [ -z "$(find "${XDG_CACHE_HOME:-$HOME/.cache}/dots/pending" -mmin -30 2>/dev/null)" ]; then
    (dots status >/dev/null 2>&1 &)
fi
