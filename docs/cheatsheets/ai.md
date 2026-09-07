# AI tools

The [maintained setup guide](../configuration/ai-agents.md) contains modes, model routing,
skills, MCP servers, installation and recovery instructions.

| Task                          | Command                              |
| ----------------------------- | ------------------------------------ |
| Codex                         | `codex`                              |
| Codex login                   | `codex login`                        |
| OpenCode                      | `opencode`                           |
| Authenticate OpenCode         | `/connect`                           |
| Choose OpenCode mode          | Tab or leader+a                      |
| Available OpenAI models       | `opencode --pure models openai`      |
| UI design                     | frontend mode or `/impeccable`       |
| Apply versioned configuration | `bash scripts/ai-setup.sh --apply`   |
| Archive the retired setup     | `bash scripts/ai-setup.sh --migrate` |
| Validate adapters             | `python3 scripts/validate-ai.py`     |
| Terminal picker               | `dots llm`                           |
| Local model runtime           | `ollama`                             |

The terminal picker includes Codex and OpenCode. Authentication and memory databases
remain private. No Claude/Cavekit installation or automatic prose compression is
part of this setup.
