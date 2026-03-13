# Windows Dev Environment Setup

This folder documents the base tools and editor setup used by these dotfiles on Windows.

Install the required tools before opening the project in VS Code or Zed. Otherwise, the editor will miss linting, formatting, type checking, and language server features.

## Related files

- VS Code settings: [Code/.vscode/settings.json](/home/oornnery/dotfiles/editor/Code/.vscode/settings.json)
- VS Code extensions: [Code/.vscode/extensions.json](/home/oornnery/dotfiles/editor/Code/.vscode/extensions.json)
- Zed settings: [Zed/.zed/settings.json](/home/oornnery/dotfiles/editor/Zed/.zed/settings.json)
- Windows bootstrap script: [../scripts/win.ps1](/home/oornnery/dotfiles/scripts/win.ps1)

## Required tools

### Python tooling

```bash
uv tool install ruff
uv tool install pyright
uv tool install ty
uv tool install rumdl
```

### JavaScript / TypeScript tooling

```bash
npm install -g typescript
npm install -g typescript-language-server
npm install -g @tailwindcss/language-server
npm install -g eslint
npm install -g prettier
```

## Tailwind setup

Use this when bootstrapping a frontend that should work well with the editor settings in this repo.

### Install packages

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### `styles.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 47.4% 11.2%;

    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 47.4% 11.2%;

    --popover: 0 0% 100%;
    --popover-foreground: 222.2 47.4% 11.2%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;

    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;

    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;

    --accent: 199 89% 48%;
    --accent-foreground: 210 40% 98%;

    --success: 142 71% 45%;
    --success-foreground: 144 61% 20%;

    --warning: 38 92% 50%;
    --warning-foreground: 26 83% 14%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --radius: 0.9rem;
  }

  .dark {
    --background: 222.2 47.4% 6%;
    --foreground: 210 40% 98%;

    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;

    --card: 222.2 47.4% 8%;
    --card-foreground: 210 40% 98%;

    --popover: 222.2 47.4% 8%;
    --popover-foreground: 210 40% 98%;

    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 97% 62%;

    --primary: 212.7 97% 62%;
    --primary-foreground: 222.2 47.4% 11.2%;

    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;

    --accent: 187 85% 53%;
    --accent-foreground: 222.2 47.4% 11.2%;

    --success: 142 69% 58%;
    --success-foreground: 144 70% 10%;

    --warning: 43 96% 56%;
    --warning-foreground: 26 83% 14%;

    --destructive: 0 72% 51%;
    --destructive-foreground: 210 40% 98%;
  }

  * {
    @apply border-border;
  }

  body {
    @apply bg-background text-foreground antialiased;
  }
}
```

### `tailwind.config.js`

Theme extended with a semantic palette inspired by Basecoat UI and shadcn.

```js
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ['class'],
  content: [
    './frontend/**/*.{ts,tsx,js,jsx}',
    './components/**/*.{ts,tsx}',
    './templates/**/*.{html,htm}',
    './templates/**/*.{jinja,jinja2,j2}',
    './docs/**/*.{md,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        success: {
          DEFAULT: 'hsl(var(--success))',
          foreground: 'hsl(var(--success-foreground))',
        },
        warning: {
          DEFAULT: 'hsl(var(--warning))',
          foreground: 'hsl(var(--warning-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        brand: {
          50: '#eef8ff',
          100: '#d8efff',
          200: '#b8e4ff',
          300: '#84d3ff',
          400: '#48bbff',
          500: '#1799ff',
          600: '#0077ff',
          700: '#005fe0',
          800: '#0a4cb5',
          900: '#103f8e',
          950: '#0d2756',
        },
        neutral: {
          50: '#fafaf9',
          100: '#f5f5f4',
          200: '#e7e5e4',
          300: '#d6d3d1',
          400: '#a8a29e',
          500: '#78716c',
          600: '#57534e',
          700: '#44403c',
          800: '#292524',
          900: '#1c1917',
          950: '#0c0a09',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      boxShadow: {
        soft: '0 10px 30px -12px rgb(0 0 0 / 0.15)',
        panel: '0 1px 2px rgb(0 0 0 / 0.06), 0 10px 24px rgb(0 0 0 / 0.08)',
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ],
}
```

### Tailwind plugins

If you use the plugins above, install them as dev dependencies too:

```bash
npm install -D @tailwindcss/forms @tailwindcss/typography @tailwindcss/container-queries
```

## Basecoat UI setup

Use this when you want shadcn-style components without depending on React. The official installation guide is here:

- Basecoat installation: [basecoatui.com/installation](https://basecoatui.com/installation/)

The official docs assume the import-based Basecoat flow. If your project is still on the classic `tailwind.config.js` setup shown above, keep that config and add Basecoat as an extra layer.

### Install package

```bash
npm install basecoat-css
```

### Import Basecoat in your CSS

Add Basecoat after Tailwind in your main stylesheet:

```css
@import 'tailwindcss';
@import 'basecoat-css';
@import './theme.css';
```

The `theme.css` import is optional, but it matches the Basecoat recommendation when you want to bring in a shadcn-compatible theme.

### `theme.css`

This is a compatible baseline if you want a semantic theme file separate from `styles.css`. It is adapted to the palette used in this README and the Basecoat theming model:

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 47.4% 11.2%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 47.4% 11.2%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 47.4% 11.2%;
  --primary: 221.2 83.2% 53.3%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 199 89% 48%;
  --accent-foreground: 210 40% 98%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 221.2 83.2% 53.3%;
  --radius: 0.9rem;
}

.dark {
  --background: 222.2 47.4% 6%;
  --foreground: 210 40% 98%;
  --card: 222.2 47.4% 8%;
  --card-foreground: 210 40% 98%;
  --popover: 222.2 47.4% 8%;
  --popover-foreground: 210 40% 98%;
  --primary: 212.7 97% 62%;
  --primary-foreground: 222.2 47.4% 11.2%;
  --secondary: 217.2 32.6% 17.5%;
  --secondary-foreground: 210 40% 98%;
  --muted: 217.2 32.6% 17.5%;
  --muted-foreground: 215 20.2% 65.1%;
  --accent: 187 85% 53%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 72% 51%;
  --destructive-foreground: 210 40% 98%;
  --border: 217.2 32.6% 17.5%;
  --input: 217.2 32.6% 17.5%;
  --ring: 212.7 97% 62%;
}
```

### Optional JavaScript

Some Basecoat components need JavaScript. If your project is ESM-aware, import all components:

```js
import 'basecoat-css/all'
```

Or only the pieces you need:

```js
import 'basecoat-css/basecoat'
import 'basecoat-css/popover'
import 'basecoat-css/tabs'
```

If you are not using a build tool, Basecoat also documents a static-file flow by copying the JS files from `node_modules/basecoat-css/dist/js`.

### Jinja / Nunjucks macros

For more complex components, Basecoat also documents a CLI flow for Jinja or Nunjucks projects. Example:

```bash
npx basecoat-cli add dialog
```

That fits well if you are using server-rendered templates and want reusable component macros.

## Recommended project configs

Use these as a baseline when starting a new project.

### `pyproject.toml`

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

select = [
  "E",
  "F",
  "I",
  "B",
  "UP"
]

fix = true

[tool.ruff.format]
quote-style = "single"

[tool.pyright]
typeCheckingMode = "standard"
reportMissingImports = true

[tool.ty]
strict = true
```

### `.rumdl.toml`

```toml
[global]
extend-enable = ["MD060"]
disable = ["MD013"]
include = ["README.md", "docs/**/*.md"]
line_length = 0

[MD060]
enabled = true
style = "aligned"
```

### `eslint.config.js`

```js
import js from '@eslint/js'

export default [js.configs.recommended]
```

### `prettier.config.js`

```js
export default {
  semi: false,
  singleQuote: true,
  trailingComma: 'es5',
  printWidth: 100,
}
```

## Validation checklist

Run these after installation:

```bash
ruff --version
pyright --version
ty --version
rumdl --version
typescript-language-server --version
eslint --version
prettier --version
```
