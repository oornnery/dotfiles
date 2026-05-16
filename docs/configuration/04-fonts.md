# Fonts

Installed via [`core/base-utils.sh`](../../../scripts/arch/core/base-utils.sh):

| Package                      | Purpose                              |
| ---------------------------- | ------------------------------------ |
| ttf-jetbrains-mono-nerd      | monospace + Nerd Font glyphs         |
| ttf-firacode-nerd            | alternate monospace + ligatures      |
| noto-fonts                   | UI / web baseline                    |
| noto-fonts-emoji             | colour emoji                         |
| noto-fonts-cjk               | CJK glyphs                           |
| woff2-font-awesome           | Font Awesome (used by waybar)        |

## Where they're used

- **Alacritty**: `JetBrainsMono Nerd Font` 11pt
- **Waybar / mako**: pulls from system fontconfig defaults
- **Hyprlock / wlogout**: configurable in each tool's config
- **Neovim**: ditto — set `vim.opt.guifont` or terminal handles it

## Quick verification

```bash
fc-list | grep -i 'jetbrains\|nerd' | head
```

If the terminal shows boxes/tofu in place of icons, the Nerd Font isn't
being picked up — verify Alacritty's `font.normal.family` matches an
installed face name.
