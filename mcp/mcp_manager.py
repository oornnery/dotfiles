#!/usr/bin/env python3.13
"""
MCP Server Manager - Install and manage Model Context Protocol servers
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Dict

try:
    import typer
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.panel import Panel
    from rich.table import Table
    from rich.prompt import Confirm, Prompt
except ImportError:
    print("Installing required dependencies...")
    subprocess.run([sys.executable, "-m", "pip", "install", "typer[all]", "rich"], check=True)
    import typer
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.panel import Panel
    from rich.table import Table
    from rich.prompt import Confirm, Prompt

app = typer.Typer(help="🔌 MCP Server Manager - Install and manage Model Context Protocol servers")
console = Console()

# MCP Servers by category
MCP_SERVERS = {
    "core": [
        "mcp-server-filesystem",
        "mcp-server-git", 
        "mcp-server-memory",
        "mcp-server-shell",
        "mcp-server-time"
    ],
    "development": [
        "mcp-server-github",
        "mcp-server-postgres", 
        "mcp-server-sqlite",
        "mcp-server-python"
    ],
    "research": [
        "mcp-server-brave-search",
        "mcp-server-obsidian",
        "mcp-server-youtube-transcript",
        "mcp-server-sequential-thinking"
    ],
    "advanced": [
        "mcp-server-puppeteer",
        "mcp-server-docker"
    ]
}

def check_uv_installed() -> bool:
    """Check if uv/uvx is installed."""
    import shutil
    return shutil.which("uvx") is not None

def install_server(server_name: str) -> bool:
    """Install a single MCP server using uvx."""
    try:
        result = subprocess.run(
            ["uvx", "install", server_name],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError:
        return False

def get_installed_servers() -> List[str]:
    """Get list of installed MCP servers."""
    try:
        result = subprocess.run(
            ["uvx", "list"],
            capture_output=True,
            text=True,
            check=True
        )
        servers = []
        for line in result.stdout.split('\n'):
            if 'mcp-server' in line:
                # Extract server name from uvx list output
                parts = line.strip().split()
                if parts:
                    servers.append(parts[0])
        return servers
    except subprocess.CalledProcessError:
        return []

@app.command()
def install(
    category: str = typer.Option("core", help="Category to install: core, development, research, advanced, all"),
    force: bool = typer.Option(False, "--force", help="Reinstall even if already installed")
):
    """🚀 Install MCP servers by category."""
    
    if not check_uv_installed():
        console.print("❌ uvx is not installed. Please install uv first:", style="red")
        console.print("curl -LsSf https://astral.sh/uv/install.sh | sh")
        raise typer.Exit(1)
    
    # Get servers to install
    if category == "all":
        servers_to_install = []
        for cat_servers in MCP_SERVERS.values():
            servers_to_install.extend(cat_servers)
    elif category in MCP_SERVERS:
        servers_to_install = MCP_SERVERS[category]
    else:
        console.print(f"❌ Unknown category: {category}", style="red")
        console.print(f"Available categories: {', '.join(MCP_SERVERS.keys())}, all")
        raise typer.Exit(1)
    
    # Check what's already installed
    installed = get_installed_servers() if not force else []
    
    # Show installation plan
    table = Table(title=f"🔌 Installing {category.title()} MCP Servers")
    table.add_column("Server", style="cyan")
    table.add_column("Status", style="green")
    
    to_install = []
    for server in servers_to_install:
        if server in installed and not force:
            table.add_row(server, "✅ Already installed")
        else:
            table.add_row(server, "📦 Will install")
            to_install.append(server)
    
    console.print(table)
    
    if not to_install:
        console.print("✅ All servers already installed!")
        return
    
    if not Confirm.ask(f"Install {len(to_install)} servers?"):
        console.print("Installation cancelled.")
        return
    
    # Install servers
    success_count = 0
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("Installing servers...", total=len(to_install))
        
        for server in to_install:
            progress.update(task, description=f"Installing {server}...")
            if install_server(server):
                console.print(f"✅ {server} installed successfully")
                success_count += 1
            else:
                console.print(f"❌ Failed to install {server}")
            progress.advance(task)
    
    console.print(f"\n🎉 Installation complete: {success_count}/{len(to_install)} servers installed")

@app.command()
def list_servers():
    """📋 List all available and installed MCP servers."""
    
    if not check_uv_installed():
        console.print("❌ uvx is not installed", style="red")
        raise typer.Exit(1)
    
    installed = get_installed_servers()
    
    for category, servers in MCP_SERVERS.items():
        table = Table(title=f"🔌 {category.title()} Servers")
        table.add_column("Server", style="cyan")
        table.add_column("Status", style="green")
        table.add_column("Description", style="dim")
        
        descriptions = {
            "mcp-server-filesystem": "Local filesystem access",
            "mcp-server-git": "Git repository operations", 
            "mcp-server-memory": "Persistent memory storage",
            "mcp-server-shell": "Shell command execution",
            "mcp-server-time": "Time and calendar operations",
            "mcp-server-github": "GitHub API integration",
            "mcp-server-postgres": "PostgreSQL database access",
            "mcp-server-sqlite": "SQLite database operations",
            "mcp-server-python": "Python code execution",
            "mcp-server-brave-search": "Web search via Brave API",
            "mcp-server-obsidian": "Obsidian notes access",
            "mcp-server-youtube-transcript": "YouTube transcript extraction",
            "mcp-server-sequential-thinking": "Enhanced reasoning",
            "mcp-server-puppeteer": "Web automation",
            "mcp-server-docker": "Docker container management"
        }
        
        for server in servers:
            status = "✅ Installed" if server in installed else "❌ Not installed"
            desc = descriptions.get(server, "MCP server")
            table.add_row(server, status, desc)
        
        console.print(table)
        console.print()

@app.command()
def uninstall(server: str):
    """🗑️ Uninstall an MCP server."""
    
    if not check_uv_installed():
        console.print("❌ uvx is not installed", style="red")
        raise typer.Exit(1)
    
    installed = get_installed_servers()
    
    if server not in installed:
        console.print(f"❌ {server} is not installed", style="red")
        raise typer.Exit(1)
    
    if Confirm.ask(f"Uninstall {server}?"):
        try:
            subprocess.run(["uvx", "uninstall", server], check=True)
            console.print(f"✅ {server} uninstalled successfully")
        except subprocess.CalledProcessError:
            console.print(f"❌ Failed to uninstall {server}")

@app.command()
def config():
    """⚙️ Generate Claude Desktop configuration."""
    
    console.print(Panel("🔧 Claude Desktop Configuration Generator", style="blue"))
    
    config_type = Prompt.ask(
        "Choose configuration type",
        choices=["development", "research", "full"],
        default="development"
    )
    
    mcp_dir = Path(__file__).parent
    
    config_files = {
        "development": mcp_dir / "claude-dev.json",
        "research": mcp_dir / "claude-research.json", 
        "full": mcp_dir / "claude-desktop.json"
    }
    
    config_file = config_files[config_type]
    
    if not config_file.exists():
        console.print(f"❌ Configuration file not found: {config_file}")
        raise typer.Exit(1)
    
    # Determine Claude Desktop config path
    import platform
    
    if platform.system() == "Darwin":
        claude_dir = Path.home() / "Library/Application Support/Claude"
    else:
        claude_dir = Path.home() / ".config/claude-desktop"
    
    claude_dir.mkdir(parents=True, exist_ok=True)
    claude_config = claude_dir / "claude_desktop_config.json"
    
    # Copy configuration
    import shutil
    shutil.copy2(config_file, claude_config)
    
    console.print(f"✅ {config_type.title()} configuration installed to {claude_config}")
    console.print("\n💡 Next steps:")
    console.print("1. Edit .env file with your API keys")
    console.print("2. Restart Claude Desktop")
    console.print("3. Test MCP integration")

@app.command()
def test(server: str):
    """🧪 Test an MCP server installation."""
    
    if not check_uv_installed():
        console.print("❌ uvx is not installed", style="red")
        raise typer.Exit(1)
    
    installed = get_installed_servers()
    
    if server not in installed:
        console.print(f"❌ {server} is not installed", style="red")
        raise typer.Exit(1)
    
    console.print(f"🧪 Testing {server}...")
    
    try:
        result = subprocess.run(
            ["uvx", "run", server, "--help"],
            capture_output=True,
            text=True,
            check=True
        )
        console.print(f"✅ {server} is working correctly")
        if result.stdout:
            console.print("\nHelp output:")
            console.print(result.stdout[:500] + "..." if len(result.stdout) > 500 else result.stdout)
    except subprocess.CalledProcessError as e:
        console.print(f"❌ {server} test failed: {e}")

if __name__ == "__main__":
    app()
