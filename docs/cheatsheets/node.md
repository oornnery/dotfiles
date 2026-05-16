# Node + Npm + Pnpm + Bun Cheatsheet

## Commands

| Command                                                   | What it does                             |
| --------------------------------------------------------- | ---------------------------------------- |
| `node -v`                                                 | Show Node.js version                     |
| `npm install`                                             | Install dependencies from `package.json` |
| `pnpm install`                                            | Faster dependency install with pnpm      |
| `bun install`                                             | Install dependencies with Bun            |
| `npm run <script>` / `pnpm <script>` / `bun run <script>` | Run project scripts                      |
| `npm outdated`                                            | Show outdated dependencies               |
| `pnpm dlx <tool>`                                         | Run tool without permanent install       |
| `bunx <tool>`                                             | Bun equivalent of `npx`                  |

## Shortcuts

| Shortcut                              | Action                                      |
| ------------------------------------- | ------------------------------------------- |
| `npx <tool>`                          | Run package binaries without global install |
| `npm test` / `pnpm test` / `bun test` | Quick test command pattern                  |

## Examples

```bash
# Install with your project package manager
pnpm install

# Run common scripts
pnpm dev
pnpm test

# One-off tools
pnpm dlx eslint --version
```

## Tips

| Tip                                       | Why it helps                |
| ----------------------------------------- | --------------------------- |
| Prefer one package manager per project    | Avoids lockfile conflicts   |
| Use pnpm for monorepos                    | Better disk usage and speed |
| Use Bun for quick scripts when compatible | Fast startup/runtime        |
| Commit lockfiles                          | Reproducible installs       |
