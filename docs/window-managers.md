# Window Managers - Configuração e Uso

## Estrutura dos Window Managers

Cada window manager possui sua própria estrutura de configuração:

```
wm/
├── i3/                 # i3 Window Manager
├── sway/               # Sway (Wayland)
├── hyprland/           # Hyprland (Wayland)
├── qtile/              # Qtile (Python-based)
├── gnome/              # GNOME Desktop
└── xfce/               # XFCE Desktop
```

## i3 Window Manager

### Características
- Window manager minimalista para X11
- Configuração baseada em texto
- Atalhos de teclado altamente customizáveis
- Suporte para workspaces múltiplos

### Arquivos de Configuração
- `wm/i3/i3/config` - Configuração principal
- `wm/i3/i3/i3blocks.conf` - Barra de status
- `wm/i3/scripts/` - Scripts auxiliares

### Atalhos Principais
- `$mod+Return` - Abrir terminal
- `$mod+d` - Launcher de aplicações
- `$mod+Shift+q` - Fechar janela
- `$mod+[1-4]` - Trocar workspace
- `$mod+Shift+[1-4]` - Mover janela para workspace

## Sway (Wayland)

### Características
- Sucessor do i3 para Wayland
- Compatível com configurações do i3
- Melhor suporte para monitores HiDPI
- Suporte nativo para Wayland

### Configuração
- `wm/sway/sway/config` - Configuração principal
- `wm/sway/scripts/` - Scripts específicos do Sway

## Hyprland (Wayland)

### Características
- Window manager moderno para Wayland
- Animações suaves e efeitos visuais
- Configuração declarativa
- Alto desempenho

### Configuração
- `wm/hyprland/hypr/hyprland.conf` - Configuração principal
- Arquivos modulares para animações, keybindings, etc.

## Qtile (Python)

### Características
- Window manager escrito em Python
- Altamente configurável via código Python
- Suporte para X11 e Wayland
- Widgets personalizáveis

### Configuração
- `wm/qtile/qtile/config.py` - Configuração principal
- `wm/qtile/qtile/components/` - Componentes modulares

## GNOME Desktop

### Características
- Ambiente desktop completo
- Interface moderna e intuitiva
- Extensões para personalização
- Suporte a Wayland e X11

### Configuração
- `wm/gnome/configure.sh` - Script de configuração automática
- Configurações via gsettings

## XFCE Desktop

### Características
- Ambiente desktop leve e rápido
- Altamente personalizável
- Baixo consumo de recursos
- Interface tradicional

### Configuração
- `wm/xfce/configure.sh` - Script de configuração
- `wm/xfce/panel.xml` - Configuração do painel

## Instalação

### Pré-requisitos
```bash
# Para todos os WMs
sudo pacman -S rofi dunst alacritty

# Específico para cada WM
sudo pacman -S i3-wm i3status i3lock    # i3
sudo pacman -S sway swaylock swayidle   # Sway
sudo pacman -S hyprland                 # Hyprland
sudo pacman -S qtile                    # Qtile
```

### Configuração Automática
```bash
# Instalar configurações do WM específico
./install.sh --wm i3        # Para i3
./install.sh --wm sway      # Para Sway
./install.sh --wm hyprland  # Para Hyprland
./install.sh --wm qtile     # Para Qtile
./install.sh --wm gnome     # Para GNOME
./install.sh --wm xfce      # Para XFCE
```

## Scripts Rofi

Todos os window managers compartilham os mesmos scripts rofi:

- `rofi/scripts/launcher.sh` - Launcher de aplicações
- `rofi/scripts/powermenu.sh` - Menu de energia
- `rofi/scripts/screenshot.sh` - Captura de tela
- `rofi/scripts/workspace-manager.sh` - Gerenciador de workspaces

## Troubleshooting

### i3 não inicia
- Verificar logs: `journalctl -b | grep i3`
- Testar configuração: `i3 -C`

### Sway não inicia
- Verificar logs: `journalctl -b | grep sway`
- Executar em modo debug: `sway -d`

### Rofi não aparece
- Verificar se está instalado: `which rofi`
- Testar manualmente: `rofi -show drun`
