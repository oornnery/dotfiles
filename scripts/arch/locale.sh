#!/usr/bin/env bash
# arch/locale.sh — locale, timezone, console keymap, X11 dual-layout.
# Runs in WSL too (locale + timezone only; skips vconsole/X11).
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

locale::run() {
  log::step "Configuring locale, timezone, keymap."

  # 1) locale.gen — uncomment en_US.UTF-8 and pt_BR.UTF-8
  snapshot /etc/locale.gen
  local l
  for l in "en_US.UTF-8 UTF-8" "pt_BR.UTF-8 UTF-8"; do
    if ! grep -q "^${l}$" /etc/locale.gen 2>/dev/null; then
      run sed -i "s/^#\s*\(${l//./\\.}\)/\1/" /etc/locale.gen
    fi
  done
  run locale-gen

  # 2) /etc/locale.conf
  if [[ $DRY_RUN -eq 0 ]]; then
    printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf
  else
    printf '%s[dry-run]%s write /etc/locale.conf LANG=%s\n' "$C_YEL" "$C_RST" "$LOCALE"
  fi

  # 3) Timezone (skip hwclock in WSL/VM)
  log::info "Setting timezone $TIMEZONE."
  run ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  if [[ ${IS_WSL:-0} -eq 0 ]] && [[ ${IS_VM:-0} -eq 0 ]]; then
    run hwclock --systohc || log::warn "hwclock --systohc failed."
  fi

  # WSL/VM stop here — no vconsole / X11 layout.
  if [[ ${IS_WSL:-0} -eq 1 ]]; then
    return 0
  fi

  # 4) Console keymap (LUKS prompt uses this — single layout)
  if [[ $DRY_RUN -eq 0 ]]; then
    printf 'KEYMAP=%s\n' "$KEYMAP" > /etc/vconsole.conf
  else
    printf '%s[dry-run]%s write /etc/vconsole.conf KEYMAP=%s\n' "$C_YEL" "$C_RST" "$KEYMAP"
  fi

  # 5) X11/Wayland dual-layout (us,br with Alt+Shift toggle)
  if [[ $DRY_RUN -eq 0 ]]; then
    install -d -m 755 /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
# Managed by scripts/arch/locale.sh — dual layout with Alt+Shift toggle.
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout"  "$XKB_LAYOUT"
    Option "XkbVariant" "$XKB_VARIANT"
    Option "XkbOptions" "$XKB_OPTIONS"
EndSection
EOF
  else
    printf '%s[dry-run]%s write /etc/X11/xorg.conf.d/00-keyboard.conf (layout=%s)\n' \
      "$C_YEL" "$C_RST" "$XKB_LAYOUT"
  fi
  log::info "X11/Wayland layout: $XKB_LAYOUT (variants: $XKB_VARIANT) — toggle: $XKB_OPTIONS"
}
