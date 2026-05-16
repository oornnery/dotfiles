#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_root

log::banner "Dev" "Languages + toolchains"

sudo pacman -S --needed --noconfirm \
    python python-pip python-pipx uv ruff pyright python-pytest \
    rust nim \
    lua luarocks \
    make cmake \
    nodejs npm fnm bun pnpm \
    go zig

log::ok "Language toolchains installed"
