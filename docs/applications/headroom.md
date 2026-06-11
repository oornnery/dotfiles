# Headroom

[Headroom](https://headroom-docs.vercel.app/) is an intelligent context compression
layer for AI agents. It reduces token usage by compressing prompts, code, and
context while preserving semantic meaning.

## Installation

Headroom is installed globally via npm (TypeScript SDK) and pipx (Python proxy).

### TypeScript SDK (Global)

```bash
npm install -g headroom-ai
```

### Python Proxy (Optional, for advanced compression)

```bash
pipx install "headroom-ai[proxy]"
```

## Usage

### TypeScript SDK

The TS SDK sends messages to the Headroom proxy over HTTP for compression.

```typescript
import { compress } from 'headroom-ai';

const result = await compress(messages, {
  baseUrl: 'http://localhost:8787',
});
```

### Starting the Proxy

If using the Python proxy for advanced compression (e.g., tree-sitter AST parsing):

```bash
headroom proxy --port 8787
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `HEADROOM_PORT` | Port the proxy listens on (default: `8787`) |
| `HEADROOM_HOST` | Host the proxy binds to (default: `0.0.0.0`) |
| `HEADROOM_MODE` | Default mode: `optimize`, `audit`, or `passthrough` |
| `OPENAI_API_KEY` | OpenAI API key (used when proxying to OpenAI) |
| `ANTHROPIC_API_KEY` | Anthropic API key (used when proxying to Anthropic) |

## Integration with Agents

Headroom can be used to compress context before sending it to KTX or directly
to LLMs, significantly reducing token costs for large codebases or long conversations.
