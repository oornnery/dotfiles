#!/usr/bin/env bash
# arch/displaymgr.sh — Display manager (login). Mutex: gdm | greetd+tuigreet | ly.
# Caller sets DM_CHOICE before calling displaymgr::run.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

# Default session command for greetd's tuigreet — orchestrator may override.
: "${DM_SESSION_CMD:=Hyprland}"

displaymgr::gdm() {
  log::info "Installing gdm (GNOME, recommended)."
  pacman_install gdm
  run systemctl enable gdm.service
  SERVICES_ENABLED+=(gdm)
  PROMPTS_APPLIED+=("gdm display manager")
}

displaymgr::greetd_tuigreet() {
  log::info "Installing greetd + tuigreet."
  pacman_install greetd greetd-tuigreet

  if [[ $DRY_RUN -eq 0 ]]; then
    install -d -m 755 /etc/greetd
    snapshot /etc/greetd/config.toml
    cat > /etc/greetd/config.toml <<EOF
# Managed by scripts/arch/displaymgr.sh
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks --cmd ${DM_SESSION_CMD}"
user = "greeter"
EOF
  else
    printf '%s[dry-run]%s write /etc/greetd/config.toml (cmd=%s)\n' \
      "$C_YEL" "$C_RST" "$DM_SESSION_CMD"
  fi
  run systemctl enable greetd.service
  SERVICES_ENABLED+=(greetd)
  PROMPTS_APPLIED+=("greetd + tuigreet display manager")
}

displaymgr::ly() {
  log::info "Installing ly (TUI ncurses)."
  pacman_install ly
  run systemctl enable ly.service
  SERVICES_ENABLED+=(ly)
  PROMPTS_APPLIED+=("ly display manager")
}

displaymgr::run() {
  log::step "Configuring display manager."
  case "${DM_CHOICE:-none}" in
    gdm)         displaymgr::gdm ;;
    greetd)      displaymgr::greetd_tuigreet ;;
    ly)          displaymgr::ly ;;
    none|"")     log::info "No display manager selected; start session manually via tty." ;;
    *)           log::warn "Unknown DM_CHOICE='$DM_CHOICE'; skipping." ;;
  esac
}
