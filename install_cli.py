#!/usr/bin/env python3.13
"""
Modern CLI installer for dotfiles using uv/uvx and rich.
Supports multiple operating systems and window managers.
"""

import os
import sys
import subprocess
import shutil
import platform
import time
from pathlib import Path
from typing import List, Optional, Dict

# Add utils to path for logger import
sys.path.append(str(Path(__file__).parent / "utils"))

try:
    import typer
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.panel import Panel
    from rich.table import Table
    from rich.prompt import Confirm
    from logger import get_logger
except ImportError:
    print("Installing required dependencies with uv...")
    subprocess.run([
        "uvx", "--from", "typer[all]", "--from", "rich", 
        "python", "-c", "import typer, rich; print('Dependencies installed!')"
    ], check=True)
    import typer
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.panel import Panel
    from rich.table import Table
    from rich.prompt import Confirm
    from logger import get_logger

app = typer.Typer(help="🏠 Modern Dotfiles Installer with uv/uvx support")
console = Console()

# Initialize logger
logger = get_logger("dotfiles_installer")

# Configuration
DOTFILES_DIR = Path(__file__).parent
CONFIG_DIR = DOTFILES_DIR / "home" / ".config"
SETUP_DIR = DOTFILES_DIR / "setup"

class SystemDetector:
    """Detect system information for intelligent installation."""
    
    @staticmethod
    def get_os() -> str:
        """Detect operating system."""
        if Path("/etc/arch-release").exists():
            return "arch"
        elif Path("/etc/debian_version").exists():
            return "debian"
        elif Path("/etc/nixos").exists():
            return "nixos"
        elif platform.system() == "Windows":
            return "windows"
        else:
            return "unknown"
    
    @staticmethod
    def get_window_manager() -> Optional[str]:
        """Detect current window manager."""
        wm_map = {
            "i3": "i3",
            "sway": "sway", 
            "hyprland": "hyprland",
            "qtile": "qtile",
            "gnome": "gnome",
            "xfce": "xfce"
        }
        
        # Check environment variables
        for env_var in ["XDG_CURRENT_DESKTOP", "DESKTOP_SESSION"]:
            if env_var in os.environ:
                desktop = os.environ[env_var].lower()
                for wm_name, wm_key in wm_map.items():
                    if wm_name in desktop:
                        return wm_key
        
        # Check running processes
        try:
            result = subprocess.run(
                ["ps", "-eo", "comm"], 
                capture_output=True, text=True, check=True
            )
            processes = result.stdout.lower()
            for wm_name, wm_key in wm_map.items():
                if wm_name in processes:
                    return wm_key
        except subprocess.SubprocessError:
            pass
        
        return None
    
    @staticmethod
    def get_installed_tools() -> Dict[str, bool]:
        """Check which tools are already installed."""
        tools = {
            "git": shutil.which("git") is not None,
            "neovim": shutil.which("nvim") is not None,
            "zsh": shutil.which("zsh") is not None,
            "docker": shutil.which("docker") is not None,
            "rofi": shutil.which("rofi") is not None,
            "uv": shutil.which("uv") is not None,
            "uvx": shutil.which("uvx") is not None,
        }
        return tools

class Installer:
    """Main installer class with rich UI."""
    
    def __init__(self):
        self.os_type = SystemDetector.get_os()
        self.wm = SystemDetector.get_window_manager()
        self.tools = SystemDetector.get_installed_tools()
        self.logger = logger  # Use the global logger instance
        
        self.logger.info("Installer initialized", {
            "os": self.os_type,
            "wm": self.wm,
            "tools_detected": sum(1 for installed in self.tools.values() if installed)
        })
        
    def show_system_info(self):
        """Display detected system information."""
        table = Table(title="🔍 System Detection")
        table.add_column("Property", style="cyan")
        table.add_column("Value", style="green")
        
        table.add_row("Operating System", self.os_type.title())
        table.add_row("Window Manager", self.wm.title() if self.wm else "Not detected")
        table.add_row("Python Version", f"{sys.version_info.major}.{sys.version_info.minor}")
        
        console.print(table)
        
        # Show installed tools
        tools_table = Table(title="🛠️ Installed Tools")
        tools_table.add_column("Tool", style="cyan")
        tools_table.add_column("Status", style="green")
        
        for tool, installed in self.tools.items():
            status = "✅ Installed" if installed else "❌ Missing"
            tools_table.add_row(tool, status)
        
        console.print(tools_table)
    
    def install_uv_if_needed(self):
        """Install uv if not present."""
        if not self.tools["uv"]:
            self.logger.installation_start("uv package manager")
            console.print("📦 Installing uv package manager...")
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console,
            ) as progress:
                progress.add_task("Installing uv...", total=None)
                try:
                    result = subprocess.run([
                        "curl", "-LsSf", "https://astral.sh/uv/install.sh", "|", "sh"
                    ], check=True, shell=True, capture_output=True, text=True)
                    self.logger.command_success("uv installation", result.stdout)
                    self.logger.installation_success("uv package manager")
                    console.print("✅ uv installed successfully!")
                except subprocess.SubprocessError as e:
                    self.logger.installation_error("uv package manager", str(e))
                    console.print(f"❌ Failed to install uv: {e}")
                    return False
        else:
            self.logger.info("uv already installed, skipping")
        return True
    
    def run_os_setup(self):
        """Run OS-specific setup."""
        setup_script = SETUP_DIR / "linux" / self.os_type / "install.sh"
        if setup_script.exists():
            self.logger.installation_start(f"{self.os_type} OS setup")
            console.print(f"🚀 Running {self.os_type} setup...")
            try:
                result = subprocess.run(
                    ["bash", str(setup_script)], 
                    check=True, 
                    capture_output=True, 
                    text=True
                )
                self.logger.command_success(f"OS setup script", result.stdout)
                self.logger.installation_success(f"{self.os_type} OS setup")
            except subprocess.SubprocessError as e:
                self.logger.installation_error(f"{self.os_type} OS setup", str(e))
                raise
        else:
            self.logger.warning(f"No setup script found for {self.os_type}")
            console.print(f"⚠️ No setup script found for {self.os_type}")
    
    def setup_window_manager(self):
        """Setup window manager configurations."""
        if not self.wm:
            self.logger.info("No window manager detected, skipping WM setup")
            return
            
        wm_dir = DOTFILES_DIR / "wm" / self.wm
        if wm_dir.exists():
            self.logger.installation_start(f"{self.wm} window manager configuration")
            console.print(f"🪟 Configuring {self.wm}...")
            # Copy configurations
            config_target = Path.home() / ".config" / self.wm
            if wm_dir.exists():
                try:
                    shutil.copytree(wm_dir, config_target, dirs_exist_ok=True)
                    self.logger.config_applied(f"{self.wm} configuration", config_target)
                    self.logger.installation_success(f"{self.wm} window manager configuration")
                    console.print(f"✅ {self.wm} configured!")
                except Exception as e:
                    self.logger.installation_error(f"{self.wm} configuration", str(e))
                    raise
        else:
            self.logger.warning(f"No configuration found for window manager: {self.wm}")
            console.print(f"⚠️ No configuration found for {self.wm}")
    
    def install_python_dev_tools(self):
        """Install Python development tools using uv."""
        self.logger.installation_start("Python development tools")
        console.print("🐍 Installing Python development tools...")
        
        tools = [
            "black",
            "isort", 
            "mypy",
            "pytest",
            "poetry",
            "pre-commit",
            "ruff"
        ]
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            for i, tool in enumerate(tools, 1):
                progress.add_task(f"Installing {tool}...", total=None)
                self.logger.step(f"Installing {tool}", len(tools), i)
                try:
                    result = subprocess.run(
                        ["uvx", "install", tool], 
                        check=True, 
                        capture_output=True, 
                        text=True
                    )
                    self.logger.command_success(f"uvx install {tool}", result.stdout)
                except subprocess.SubprocessError as e:
                    self.logger.command_error(f"uvx install {tool}", str(e))
                    console.print(f"⚠️ Failed to install {tool}")
        
        self.logger.installation_success("Python development tools")
        console.print("✅ Python development tools installed!")
    
    def setup_shell_config(self):
        """Setup shell configurations."""
        self.logger.installation_start("shell configurations")
        console.print("🐚 Setting up shell configurations...")
        
        # ZSH setup
        zsh_source = DOTFILES_DIR / "shells" / "zsh"
        zsh_target = Path.home() / ".config" / "zsh"
        
        if zsh_source.exists():
            try:
                shutil.copytree(zsh_source, zsh_target, dirs_exist_ok=True)
                self.logger.config_applied("ZSH configuration", zsh_target)
            except Exception as e:
                self.logger.error(f"Failed to copy ZSH configuration: {e}")
        
        # Setup symlinks for common files
        dotfiles_map = {
            "shells/zsh/.zshrc": ".zshrc",
            "home/.config/git/gitconfig": ".gitconfig",
            "home/.config/neovim": ".config/nvim"
        }
        
        for source, target in dotfiles_map.items():
            source_path = DOTFILES_DIR / source
            target_path = Path.home() / target
            
            if source_path.exists():
                self.logger.step(f"Creating symlink for {target}")
                target_path.parent.mkdir(parents=True, exist_ok=True)
                if target_path.is_symlink():
                    target_path.unlink()
                    self.logger.info(f"Removed existing symlink: {target_path}")
                elif target_path.exists():
                    backup_path = Path(f"{target_path}.backup")
                    shutil.move(str(target_path), str(backup_path))
                    self.logger.backup_created(backup_path)
                try:
                    target_path.symlink_to(source_path.absolute())
                    self.logger.config_applied(f"symlink {target}", target_path)
                except Exception as e:
                    self.logger.error(f"Failed to create symlink {target}: {e}")
        
        self.logger.installation_success("shell configurations")
        console.print("✅ Shell configurations setup complete!")

@app.command()
def install(
    mode: str = typer.Option("full", help="Installation mode: full, config-only, python-dev, shell-setup"),
    force: bool = typer.Option(False, "--force", help="Force installation without prompts"),
    skip_system: bool = typer.Option(False, "--skip-system", help="Skip system package installation")
):
    """🏠 Install dotfiles with intelligent detection."""
    
    installer = Installer()
    
    # Log installation start
    installer.logger.installation_start("dotfiles", mode)
    installer.logger.info(f"Installation mode: {mode}, force: {force}, skip_system: {skip_system}")
    
    # Show welcome message
    console.print(Panel.fit(
        "🏠 [bold blue]Modern Dotfiles Installer[/bold blue]\n"
        "Using Python 3.13 + uv/uvx + rich",
        title="Welcome"
    ))
    
    # Show system info
    installer.show_system_info()
    
    if not force:
        if not Confirm.ask("Continue with installation?"):
            installer.logger.info("Installation cancelled by user")
            console.print("Installation cancelled.")
            return
    
    # Install uv if needed
    if not installer.install_uv_if_needed():
        installer.logger.error("Failed to install uv, aborting")
        return
    
    start_time = time.time()
    
    try:
        if mode in ["full", "config-only"]:
            installer.setup_shell_config()
            installer.setup_window_manager()
        
        if mode in ["full", "python-dev"]:
            installer.install_python_dev_tools()
        
        if mode == "full" and not skip_system:
            installer.run_os_setup()
        
        duration = time.time() - start_time
        installer.logger.installation_success("dotfiles", duration)
        
        console.print(Panel.fit(
            "✅ [bold green]Installation completed successfully![/bold green]\n"
            "Your dotfiles are now configured.",
            title="Success"
        ))
        
        # Show log summary
        installer.logger.show_log_summary()
        
    except Exception as e:
        installer.logger.installation_error("dotfiles", str(e))
        console.print(f"❌ Installation failed: {e}")
        raise typer.Exit(1)

@app.command()
def status():
    """📊 Show current system status and installed tools."""
    installer = Installer()
    installer.show_system_info()

@app.command()
def logs():
    """📋 Show recent installation logs."""
    logger.show_log_summary()

@app.command() 
def backup():
    """💾 Create backup of current configurations."""
    logger.installation_start("backup creation")
    
    backup_dir = Path.home() / ".dotfiles_backup"
    backup_dir.mkdir(exist_ok=True)
    
    console.print(f"📦 Creating backup in {backup_dir}...")
    
    # Backup common config files
    configs_to_backup = [
        ".zshrc", ".bashrc", ".gitconfig", 
        ".config/nvim", ".config/i3", ".config/sway"
    ]
    
    backed_up_count = 0
    for config in configs_to_backup:
        source = Path.home() / config
        if source.exists():
            target = backup_dir / config
            target.parent.mkdir(parents=True, exist_ok=True)
            try:
                if source.is_dir():
                    shutil.copytree(source, target, dirs_exist_ok=True)
                else:
                    shutil.copy2(source, target)
                logger.config_applied(f"backup {config}", target)
                backed_up_count += 1
            except Exception as e:
                logger.error(f"Failed to backup {config}: {e}")
    
    logger.backup_created(backup_dir)
    logger.installation_success("backup creation")
    console.print(f"✅ Backup completed: {backup_dir} ({backed_up_count} items)")

@app.command()
def update():
    """🔄 Update dotfiles repository and reinstall."""
    logger.installation_start("dotfiles update")
    console.print("🔄 Updating dotfiles...")
    
    try:
        # Git pull
        result = subprocess.run(
            ["git", "pull"], 
            cwd=DOTFILES_DIR, 
            check=True, 
            capture_output=True, 
            text=True
        )
        logger.command_success("git pull", result.stdout)
        
        # Reinstall
        installer = Installer()
        installer.setup_shell_config()
        installer.setup_window_manager()
        
        logger.installation_success("dotfiles update")
        console.print("✅ Dotfiles updated!")
        
    except subprocess.SubprocessError as e:
        logger.command_error("git pull", str(e))
        logger.installation_error("dotfiles update", str(e))
        console.print(f"❌ Update failed: {e}")
        raise typer.Exit(1)

if __name__ == "__main__":
    app()
