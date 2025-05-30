#!/bin/bash
# MCP Setup Script - Install and configure Model Context Protocol servers

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# MCP servers to install
declare -a CORE_SERVERS=(
    "mcp-server-filesystem"
    "mcp-server-git"
    "mcp-server-memory"
    "mcp-server-shell"
    "mcp-server-time"
)

declare -a DEV_SERVERS=(
    "mcp-server-github"
    "mcp-server-postgres"
    "mcp-server-sqlite"
    "mcp-server-python"
)

declare -a RESEARCH_SERVERS=(
    "mcp-server-brave-search"
    "mcp-server-obsidian"
    "mcp-server-youtube-transcript"
    "mcp-server-sequential-thinking"
)

declare -a ADVANCED_SERVERS=(
    "mcp-server-puppeteer"
    "mcp-server-docker"
)

# Check if uv/uvx is installed
check_uv() {
    if ! command -v uvx &> /dev/null; then
        log_error "uvx is not installed. Please install uv first:"
        echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    log_success "uvx is available"
}

# Install MCP servers
install_servers() {
    local servers=("$@")
    
    for server in "${servers[@]}"; do
        log_info "Installing $server..."
        if uvx install "$server" &> /dev/null; then
            log_success "✓ $server installed"
        else
            log_warning "⚠ Failed to install $server"
        fi
    done
}

# Setup environment file
setup_environment() {
    local env_file="$SCRIPT_DIR/.env"
    local env_example="$SCRIPT_DIR/.env-example"
    
    if [[ ! -f "$env_file" ]]; then
        log_info "Creating .env file from template..."
        cp "$env_example" "$env_file"
        log_warning "Please edit $env_file with your API keys and configuration"
    else
        log_info ".env file already exists"
    fi
}

# Setup Claude Desktop configuration
setup_claude_desktop() {
    local config_dir
    
    # Determine Claude Desktop config directory
    if [[ "$OSTYPE" == "darwin"* ]]; then
        config_dir="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        config_dir="$HOME/.config/claude-desktop"
        mkdir -p "$config_dir"
        config_dir="$config_dir/claude_desktop_config.json"
    else
        log_warning "Unsupported OS for automatic Claude Desktop setup"
        return
    fi
    
    log_info "Setting up Claude Desktop configuration..."
    
    # Ask user which configuration to use
    echo "Choose Claude Desktop configuration:"
    echo "1) Full development setup (all servers)"
    echo "2) Development focus (coding servers)"
    echo "3) Research focus (research servers)"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            cp "$SCRIPT_DIR/claude-desktop.json" "$config_dir"
            log_success "Full development configuration installed"
            ;;
        2)
            cp "$SCRIPT_DIR/claude-dev.json" "$config_dir"
            log_success "Development configuration installed"
            ;;
        3)
            cp "$SCRIPT_DIR/claude-research.json" "$config_dir"
            log_success "Research configuration installed"
            ;;
        *)
            log_warning "Invalid choice. Manual setup required."
            ;;
    esac
}

# Test MCP servers
test_servers() {
    log_info "Testing installed MCP servers..."
    
    local installed_servers
    installed_servers=$(uvx list 2>/dev/null | grep "mcp-server" | cut -d' ' -f1 || true)
    
    if [[ -z "$installed_servers" ]]; then
        log_warning "No MCP servers found"
        return
    fi
    
    echo "Installed MCP servers:"
    echo "$installed_servers" | while read -r server; do
        if [[ -n "$server" ]]; then
            echo "  ✓ $server"
        fi
    done
}

# Main installation function
main() {
    log_info "🚀 MCP Setup Script"
    echo "This script will install and configure Model Context Protocol servers"
    echo
    
    # Check prerequisites
    check_uv
    
    # Ask what to install
    echo "What would you like to install?"
    echo "1) Core servers only (filesystem, git, memory, shell, time)"
    echo "2) Development setup (core + github, postgres, sqlite, python)"
    echo "3) Research setup (core + search, obsidian, youtube, thinking)"
    echo "4) Everything (all available servers)"
    echo "5) Custom selection"
    read -p "Enter choice (1-5): " install_choice
    
    case $install_choice in
        1)
            log_info "Installing core servers..."
            install_servers "${CORE_SERVERS[@]}"
            ;;
        2)
            log_info "Installing development setup..."
            install_servers "${CORE_SERVERS[@]}" "${DEV_SERVERS[@]}"
            ;;
        3)
            log_info "Installing research setup..."
            install_servers "${CORE_SERVERS[@]}" "${RESEARCH_SERVERS[@]}"
            ;;
        4)
            log_info "Installing all servers..."
            install_servers "${CORE_SERVERS[@]}" "${DEV_SERVERS[@]}" "${RESEARCH_SERVERS[@]}" "${ADVANCED_SERVERS[@]}"
            ;;
        5)
            echo "Available server categories:"
            echo "  core: ${CORE_SERVERS[*]}"
            echo "  dev: ${DEV_SERVERS[*]}"
            echo "  research: ${RESEARCH_SERVERS[*]}"
            echo "  advanced: ${ADVANCED_SERVERS[*]}"
            read -p "Enter space-separated list of categories: " categories
            
            for category in $categories; do
                case $category in
                    core) install_servers "${CORE_SERVERS[@]}" ;;
                    dev) install_servers "${DEV_SERVERS[@]}" ;;
                    research) install_servers "${RESEARCH_SERVERS[@]}" ;;
                    advanced) install_servers "${ADVANCED_SERVERS[@]}" ;;
                    *) log_warning "Unknown category: $category" ;;
                esac
            done
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Setup environment
    setup_environment
    
    # Setup Claude Desktop
    if command -v claude &> /dev/null || [[ -d "$HOME/Library/Application Support/Claude" ]] || [[ -d "$HOME/.config/claude-desktop" ]]; then
        read -p "Setup Claude Desktop configuration? (y/N): " setup_claude
        if [[ "$setup_claude" =~ ^[Yy]$ ]]; then
            setup_claude_desktop
        fi
    fi
    
    # Test installation
    test_servers
    
    # Final instructions
    echo
    log_success "🎉 MCP setup completed!"
    echo
    echo "Next steps:"
    echo "1. Edit $SCRIPT_DIR/.env with your API keys"
    echo "2. Restart Claude Desktop if you configured it"
    echo "3. Test MCP servers: uvx mcp-server-filesystem --help"
    echo
    echo "For more information, see: $SCRIPT_DIR/README.md"
}

# Run main function
main "$@"
