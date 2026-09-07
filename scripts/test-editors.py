#!/usr/bin/env python3
"""Exercise native Vim/Neovim workflows without fetching plugins or calling AI."""
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
TEST = ROOT / "scripts/tests/editors.vim"

with tempfile.TemporaryDirectory(prefix="dotfiles-editors-") as directory:
    scratch = Path(directory)
    project = scratch / "project"
    (project / "sub").mkdir(parents=True)
    (project / ".git").mkdir()
    (project / "sub/sample.py").write_text('print("hello")\n')
    for editor in ("vim", "nvim"):
        for profile in ("full", "basic", "auto"):
            result = scratch / f"{editor}-{profile}.txt"
            env = {**os.environ, "DOTFILES_TERMINAL": profile,
                   "TERM_PROGRAM": "MobaXterm",
                   "DOTFILES_EDITOR_EXPECT_BASIC": "0" if profile == "full" else "1",
                   "DOTFILES_NVIM_PLUGINS": "0", "DOTFILES_EDITOR_FIXTURE": str(project),
                   "DOTFILES_EDITOR_RESULT": str(result),
                   "XDG_CACHE_HOME": str(scratch / "cache"),
                   "XDG_STATE_HOME": str(scratch / "state"),
                   "XDG_DATA_HOME": str(scratch / "data")}
            if editor == "nvim":
                config = ROOT / "nvim/.config/nvim"
                command = [editor, "--headless", "--cmd", f"set runtimepath^={config}",
                           "-u", str(config / "init.lua")]
            else:
                command = [editor, "-es", "-u", str(ROOT / "vim/.vimrc")]
            run = subprocess.run([*command, "-i", "NONE", "-n", "-S", str(TEST)],
                                 env=env, capture_output=True, text=True, timeout=30)
            report = result.read_text().strip() if result.exists() else "test did not finish"
            if run.returncode or report != "PASS":
                raise SystemExit(f"FAIL {editor}/{profile}: {report}\n{run.stdout}{run.stderr}")
            print(f"PASS {editor}/{profile}: startup, keys, comments, project root, explorer")
