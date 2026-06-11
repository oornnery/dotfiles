# Windows Dev Environment Setup

This folder documents the base tools and editor setup used by these dotfiles on Windows.

Install the required tools before opening the project in VS Code or Zed. Otherwise, the editor will miss linting, formatting, type checking, and language server features.

## Related files

- VS Code settings: [Code/.vscode/settings.json](/home/oornnery/dotfiles/editor/Code/.vscode/settings.json)
- VS Code extensions: [Code/.vscode/extensions.json](/home/oornnery/dotfiles/editor/Code/.vscode/extensions.json)
- Zed settings: [Zed/.zed/settings.json](/home/oornnery/dotfiles/editor/Zed/.zed/settings.json)

Install all extensions `grep -v '//' extensions.json | jq -r '.recommendations[]' | xargs -n 1 code-oss --install-extension`

Note: I migrated `.vscode/settings.json` to be managed with Stow for use with `Code - OSS`. To enable the official extensions marketplace, you need to install the `code-marketplace` package from the AUR.