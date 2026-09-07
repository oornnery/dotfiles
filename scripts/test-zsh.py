#!/usr/bin/env python3
"""Offline regression tests for shell initialization, without loading user plugins."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
RC = (ROOT / "zsh/.zshrc").read_text()


def function(name):
    match = re.search(rf"^{re.escape(name)}\(\) \{{\n.*?^\}}", RC, re.M | re.S)
    if not match:
        raise AssertionError(f"Missing function: {name}")
    return match.group()


class ZshTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="dotfiles-zsh-test-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = dict(os.environ, XDG_CACHE_HOME=str(self.root / "cache"),
                        TEST_LOG=str(self.root / "calls"))
        self.env["PATH"] = f"{self.root}:/usr/bin:/bin"

    def run_zsh(self, code, check=True):
        return subprocess.run(["zsh", "-fc", code], env=self.env, text=True,
                              capture_output=True, check=check, timeout=15)

    def fake(self, name, code):
        target = self.root / name
        target.write_text("#!/bin/sh\n" + code + "\n")
        target.chmod(0o700)

    def completion(self, force=0, check=True):
        code = function("_dotfiles_opencode_completion")
        return self.run_zsh(code + f"\ncommand -v opencode >/dev/null\n"
                            f"_dotfiles_opencode_completion {force}\n", check)

    def valid_cli(self, extra=""):
        self.fake("opencode", 'echo call >> "$TEST_LOG"\n'
                  'echo "typeset -g completion_loaded=yes"\n' + extra)

    def calls(self):
        return len((self.root / "calls").read_text().splitlines())

    def test_completion_cold_warm_force_and_upgrade(self):
        self.valid_cli()
        self.completion()
        cache = self.root / "cache/zsh/opencode-completion.zsh"
        self.assertEqual(cache.stat().st_mode & 0o777, 0o600)
        self.completion()
        self.assertEqual(self.calls(), 1)
        result = self.run_zsh(function("_dotfiles_opencode_completion") +
                              '\ncommand -v opencode >/dev/null\n'
                              '_dotfiles_opencode_completion\nprint -r -- "$completion_loaded"')
        self.assertEqual(result.stdout.strip(), "yes")
        self.completion(force=1)
        self.assertEqual(self.calls(), 2)
        self.valid_cli("# replacement with a different size")
        self.completion()
        self.assertEqual(self.calls(), 3)

    def test_failed_generation_preserves_cache(self):
        self.valid_cli()
        self.completion()
        cache = self.root / "cache/zsh/opencode-completion.zsh"
        previous = cache.read_bytes()
        for output in ('echo partial; exit 1', 'echo "if then"'):
            self.fake("opencode", output)
            self.assertNotEqual(self.completion(check=False).returncode, 0)
            self.assertEqual(cache.read_bytes(), previous)
            self.assertEqual(list(cache.parent.glob("opencode-completion.*")), [cache])

    def test_deferred_generation_and_synchronous_fallback(self):
        for tool in ("fnm", "atuin", "mise", "direnv"):
            self.fake(tool, f'echo {tool} >> "$TEST_LOG"\necho "typeset -g {tool}_ready=yes"')
        section = RC[RC.index("# direnv must establish"):RC.index("# opencode\n")]
        code = function("_dotfiles_init_tool") + "\n" + section
        self.run_zsh(code + '\n[[ $fnm_ready == yes && $atuin_ready == yes && '
                     '$mise_ready == yes && $direnv_ready == yes ]]')
        self.assertEqual(self.calls(), 4)
        (self.root / "calls").unlink()
        deferred = ('typeset -a pending\nzsh-defer() { pending+=("${(j: :)@}"); }\n'
                    + code + '\n[[ $direnv_ready == yes && -z $fnm_ready ]] || exit 1\n'
                    '[[ $(wc -l < "$TEST_LOG") == 1 ]] || exit 2\n'
                    'for callback in "${pending[@]}"; do eval "$callback"; done\n'
                    '[[ $fnm_ready == yes && $atuin_ready == yes && $mise_ready == yes ]]')
        self.run_zsh(deferred)
        self.assertEqual(self.calls(), 4)

    def test_path_is_unique(self):
        self.run_zsh('path=(/bin /usr/bin /bin); typeset -U path PATH; '
                     'export PATH="/bin:$PATH"; [[ $#path == 2 ]]')

    def test_no_pane_input_injection(self):
        self.assertNotRegex(RC, r"command zellij action write-chars")


if __name__ == "__main__":
    unittest.main(verbosity=2)
