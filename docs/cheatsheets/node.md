# Node

mise gives Node (LTS by default, a project can ask for its own); pnpm installs the
packages. Setup: `dots install node`.

## Node versions (mise)

| Task | Command |
| ---- | ------- |
| The version here | `node -v`, `mise current` |
| A version for this project | `mise use node@22` (writes `mise.toml`) |
| Every version | `mise ls`, available: `mise ls-remote node` |
| The default | `~/.config/mise/config.toml` (`node = "lts"`) |
| Projects with `.nvmrc` or `.node-version` | mise reads them too |

## A project (pnpm)

| Task | Command |
| ---- | ------- |
| New | `pnpm init`; with a template: `pnpm create vite app` |
| Install | `pnpm i` |
| Add | `pnpm add zod`, dev: `pnpm add -D vitest` |
| Remove | `pnpm remove zod` |
| Run a script | `pnpm dev`, `pnpm test`, `pnpm run build` |
| Run a package once | `pnpm dlx create-hono app` (like `npx`) |
| Outdated, update | `pnpm outdated`, `pnpm up --latest` |
| Why it is there | `pnpm why pkg` |

npm works the same (`npm i`, `npm run x`, `npx x`). Global tools: `dots pkg add -m npm x`.

## TypeScript

| Task | Command |
| ---- | ------- |
| Start | `pnpm add -D typescript`, `pnpm tsc --init` |
| Check | `pnpm tsc --noEmit` |
| Run a .ts file | `node file.ts` (Node 23.6+ runs TypeScript by stripping the types), or `pnpm dlx tsx file.ts` |

Helix uses `typescript-language-server`.

## Common libraries

| For | Library |
| --- | ------- |
| Validation | `zod` |
| Tests | `vitest` |
| Lint and format | `biome` (one tool), or `eslint` + `prettier` |
| Web server | `hono`, `fastify`, `express` |
| Database | `drizzle-orm`, `prisma` |
| Front end | `vite`; React, Svelte, Vue templates with `pnpm create vite` |
| CLI | `commander`; prompts: `@clack/prompts` |
| Env files | `node --env-file=.env app.js` (built in), `dotenvx` |

The npm cache and the REPL history live outside `$HOME` (`env.d/node.sh`).
