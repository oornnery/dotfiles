#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
ENABLE_HERDR="${ENABLE_HERDR:-1}"

require_root

log::banner "Dev" "Herdr — agent multiplexer"

if [[ $ENABLE_HERDR -ne 1 ]]; then
    log::skip "Herdr disabled (ENABLE_HERDR=0)"
    exit 0
fi

if ! id "$USER_NAME" >/dev/null 2>&1; then
    die "User $USER_NAME doesn't exist"
fi

log::step "Installing Herdr"

if sudo -u "$USER_NAME" -H bash -c 'command -v "$1"' _ herdr >/dev/null 2>&1; then
    log::skip "herdr already installed ($(sudo -u "$USER_NAME" -H bash -c 'herdr --version 2>/dev/null || echo unknown'))"
else
    log::info "Installing via official installer"
    sudo -u "$USER_NAME" -H bash -o pipefail -c 'curl -fsSL https://herdr.dev/install.sh | sh' || \
        die "Herdr install failed (check network / installer)"
    log::ok "Herdr installed (run 'herdr' to launch)"
fi

log::step "Stowing herdr config"
stow_safe herdr

# ─── Plugins ────────────────────────────────────────────────────────────────
# config.toml binds plugin actions, but plugins/ and plugins.json are runtime
# state (gitignored), so this list is the only reproducible record of the plugin
# set. Pinned to commits; `herdr plugin list` reports the same refs.
log::step "Installing pinned plugins"

user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
run_as_user() { as_user "$USER_NAME" bash -c "$1"; }

HERDR_PLUGINS=(
    "thanhdat77/herdr-navigator|8e90917a1a635682e435aa4627c59b3e6f7942b6|herdr-navigator"
    "nicosuave/memex|a4f8152efa05368114a85117cb0445a930bee8d2|nicosuave.memex"
    "rjyo/herdr-window-title-sync|b07f1140b7308d66487b2f4be546c0c7db065569|rjyo.window-title-sync"
)

installed_plugins="$(run_as_user 'herdr plugin list 2>/dev/null' || true)"
for entry in "${HERDR_PLUGINS[@]}"; do
    IFS='|' read -r repo rev id <<<"$entry"
    if grep -qF -- "- $id " <<<"$installed_plugins"; then
        log::skip "plugin '$id' already installed"
    elif run_as_user "herdr plugin install '$repo' --ref '$rev' -y" >/dev/null 2>&1; then
        log::ok "plugin $id @ ${rev:0:7}"
    else
        # herdr-navigator builds with cargo; a missing toolchain is not fatal.
        log::warn "plugin '$id' failed — try 'herdr plugin install $repo --ref $rev -y' manually"
    fi
done

# vim-herdr-navigation is a local plugin (herdr plugin link), not a GitHub
# install: one checkout ships both the herdr action and the editor side.
NAV_SRC="${HERDR_PLUGIN_SRC_DIR:-$user_home/.local/share/herdr/plugins-src}/vim-herdr-navigation"
NAV_REPO="https://github.com/paulbkim-dev/vim-herdr-navigation"
NAV_REV="79679dacc791f70fc34de8b29a3cf9706c0f5b2f"
NAV_PARENT="$(dirname "$NAV_SRC")"

log::step "Linking vim-herdr-navigation"
if ! run_as_user 'command -v jq' >/dev/null 2>&1; then
    # navigate.sh still moves herdr focus without jq; it just cannot tell whether
    # the focused pane runs Vim, so the split-edge hand-off stops working.
    log::warn "jq not installed — vim-herdr-navigation will ignore Vim panes"
fi
if run_as_user "test -d '$NAV_SRC/.git'"; then
    log::skip "already cloned: $NAV_SRC"
elif run_as_user "mkdir -p '$NAV_PARENT' && git clone -q '$NAV_REPO' '$NAV_SRC'"; then
    log::ok "cloned $NAV_REPO"
else
    log::warn "clone failed: $NAV_REPO"
fi
if run_as_user "git -C '$NAV_SRC' fetch -q origin '$NAV_REV' && git -C '$NAV_SRC' checkout -q '$NAV_REV'"; then
    :
else
    log::warn "could not pin $NAV_SRC at ${NAV_REV:0:7} (keeping the checked-out revision)"
fi

installed_plugins="$(run_as_user 'herdr plugin list 2>/dev/null' || true)"
if grep -qF -- "- vim-herdr-navigation" <<<"$installed_plugins"; then
    log::skip "plugin 'vim-herdr-navigation' already linked"
elif run_as_user "herdr plugin link '$NAV_SRC'" >/dev/null 2>&1; then
    log::ok "linked $NAV_SRC @ ${NAV_REV:0:7}"
else
    log::warn "herdr plugin link failed for $NAV_SRC"
fi

# ─── Agent integrations ────────────────────────────────────────────────────
# Lifecycle state + native session restore per client, only for CLIs that are
# actually present; `herdr integration status` reports the rest as not installed.
log::step "Agent integrations"
for agent in codex opencode claude pi; do
    case "$agent" in
        claude|pi)
            run_as_user "command -v $agent" >/dev/null 2>&1 || {
                log::skip "$agent CLI not installed"
                continue
            }
            ;;
    esac
    if run_as_user "herdr integration install $agent" >/dev/null 2>&1; then
        log::ok "integration $agent"
    else
        log::warn "integration '$agent' failed"
    fi
done

if run_as_user 'herdr server reload-config' >/dev/null 2>&1; then
    log::ok "running server reloaded config.toml"
else
    log::info "no running herdr server — new keybindings apply on next start"
fi

log::ok "Herdr setup completed"
