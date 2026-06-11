#!/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/../editor/Code/.vscode/extensions.json"

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    echo "Error: extensions file not found at $EXTENSIONS_FILE" >&2
    exit 1
fi

grep -v '//' "$EXTENSIONS_FILE" | jq -r '.recommendations[]' | while read -r ext; do
    code --install-extension "$ext"
done

