# KTX

[KTX](https://docs.kaelio.com/ktx/) is the open-source context layer for data agents.
It connects your databases and context sources to AI agents, providing enriched
schema, semantic layers, and intelligent context compression.

## Global OpenCode Configuration

KTX is configured globally for OpenCode in this environment.

### Configuration

The OpenCode config at `~/.config/opencode/opencode.jsonc` includes the KTX MCP server:

```jsonc
{
  "plugin": ["oh-my-openagent@latest"],
  "mcp": {
    "ktx": {
      "type": "remote",
      "url": "http://localhost:7878/mcp",
      "enabled": true
    }
  }
}
```

### Usage

1. **Start the MCP server** (required before using OpenCode):
   ```bash
   ktx mcp start --project-dir ~
   ```

2. **Stop the MCP server**:
   ```bash
   ktx mcp stop --project-dir ~
   ```

3. **Check status**:
   ```bash
   ktx status --json --no-input
   ```

### Adding a Database

KTX requires a database connection to build context. To add one:

```bash
ktx setup --no-input --yes --project-dir ~ \
  --database <driver> \
  --database-connection-id <id> \
  --database-url 'file:/absolute/path/to/db' \
  --database-schema <schema> \
  --skip-llm --skip-sources --skip-agents
```

After adding a database, ingest its context:
```bash
ktx ingest <connection-id> --no-input
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP not connecting | Ensure `ktx mcp start` is running |
| LLM not ready | Run `ktx setup` with `--llm-backend anthropic --anthropic-api-key-env ANTHROPIC_API_KEY` |
| Database connection fails | Verify the `file:` path exists and is readable |
