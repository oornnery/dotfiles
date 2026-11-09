# pet: how to use it

Command snippets: the long commands you do not want to remember. The list is
`home/pet/.config/pet/snippet.toml`, in the repo; `dots help pet` lists them.

## Use

| Task | How |
| ---- | --- |
| Insert a snippet in the line | `Ctrl x Ctrl r`, pick, then edit before Enter |
| Run one | `pet exec` |
| From the palette | `Alt /`, the `pet` mode |
| Save the last command | `prev` |
| Save a new one | `pet new` |
| Edit them all | `pet edit` (the TOML) |
| List | `pet list` |

## Parameters

`<name=default>` in a command is asked for when it runs:

```toml
[[snippets]]
  description = "biggest files and folders here"
  command = "du -ahx <dir=.> 2>/dev/null | sort -rh | head -<n=20>"
  tag = ["files", "disk"]
```

Sections in the file start with `# ── Name ──`; `dots help pet` groups by them.
