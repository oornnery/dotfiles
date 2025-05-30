#!/bin/bash

# Script moderno para workspace/virtual desktop manager
# Compatível com i3, sway, hyprland

# Detectar window manager
if pgrep -x "i3" > /dev/null; then
    WM="i3"
elif pgrep -x "sway" > /dev/null; then
    WM="sway"  
elif pgrep -x "hyprland" > /dev/null; then
    WM="hyprland"
else
    notify-send "Erro" "Window manager não suportado"
    exit 1
fi

# Função para listar workspaces
list_workspaces() {
    case $WM in
        "i3"|"sway")
            if [ "$WM" = "i3" ]; then
                i3-msg -t get_workspaces | jq -r '.[] | "\(.num): \(.name) (\(.windows) windows)"'
            else
                swaymsg -t get_workspaces | jq -r '.[] | "\(.num): \(.name) (\(.windows) windows)"'
            fi
            ;;
        "hyprland")
            hyprctl workspaces | grep "workspace ID" | awk '{print $3 ": Workspace " $3}'
            ;;
    esac
}

# Opções do menu
options="📋 Listar Workspaces\n➕ Novo Workspace\n🔄 Próximo Workspace\n⬅️ Workspace Anterior\n🎯 Ir para Workspace"

chosen=$(echo -e "$options" | rofi -dmenu -p "Workspace Manager" -theme-str 'window {width: 35%;}')

case "$chosen" in
    "📋 Listar Workspaces")
        workspaces=$(list_workspaces)
        echo "$workspaces" | rofi -dmenu -p "Workspaces Ativos" -theme-str 'window {width: 50%;}'
        ;;
    "➕ Novo Workspace")
        workspace_num=$(rofi -dmenu -p "Número do novo workspace:")
        if [ -n "$workspace_num" ]; then
            case $WM in
                "i3") i3-msg "workspace $workspace_num" ;;
                "sway") swaymsg "workspace $workspace_num" ;;
                "hyprland") hyprctl dispatch workspace "$workspace_num" ;;
            esac
        fi
        ;;
    "🔄 Próximo Workspace")
        case $WM in
            "i3") i3-msg "workspace next" ;;
            "sway") swaymsg "workspace next" ;;
            "hyprland") hyprctl dispatch workspace e+1 ;;
        esac
        ;;
    "⬅️ Workspace Anterior")
        case $WM in
            "i3") i3-msg "workspace prev" ;;
            "sway") swaymsg "workspace prev" ;;
            "hyprland") hyprctl dispatch workspace e-1 ;;
        esac
        ;;
    "🎯 Ir para Workspace")
        workspace_num=$(rofi -dmenu -p "Ir para workspace:")
        if [ -n "$workspace_num" ]; then
            case $WM in
                "i3") i3-msg "workspace $workspace_num" ;;
                "sway") swaymsg "workspace $workspace_num" ;;
                "hyprland") hyprctl dispatch workspace "$workspace_num" ;;
            esac
        fi
        ;;
esac
