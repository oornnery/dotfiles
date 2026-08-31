# OpenCode runtime

## RTK

`openrtk` rewrites supported shell commands automatically. Run normal commands;
do not manually prefix ordinary Git/test commands with `rtk`.

Use RTK meta commands directly:

```bash
rtk gain
rtk gain --history
rtk discover
rtk proxy <cmd>
```

When compressed output omits evidence needed for diagnosis, use `rtk proxy` for
that one command.

## Sessions and subagents

Read-only commands intentionally use child sessions. Navigation:

```text
Ctrl+Alt+J  first child
Ctrl+Alt+L  next child
Ctrl+Alt+H  previous child
Ctrl+Alt+K  parent
```

Implementation commands set `subtask: false` so work remains in current session.

## Model and agent checks

```bash
opencode models
opencode agent list
opencode debug agent <name>
opencode debug skill <name>
```
