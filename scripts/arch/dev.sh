#!/usr/bin/env bash
# arch/dev.sh — Programming languages + toolchains.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

dev::run() {
  log::step "Installing dev stack."
  pacman_install \
    python python-pipx uv ruff ty rumdl \
    rust nim \
    lua luarocks \
    make cmake \
    nodejs npm fnm bun pnpm \
    go zig
  PROMPTS_APPLIED+=("dev stack")
}
