#!/usr/bin/env python3
"""
Advanced logging system for dotfiles installation and management.
"""

import logging
from datetime import datetime
from pathlib import Path
from typing import Optional

from rich.console import Console
from rich.logging import RichHandler
from rich.theme import Theme

# Rich theme for consistent styling
custom_theme = Theme({
    "info": "cyan",
    "warning": "yellow",
    "error": "red bold",
    "success": "green bold",
    "debug": "magenta dim",
})

console = Console(theme=custom_theme)


class DotfilesLogger:
    """Advanced logger for dotfiles operations with rich formatting and file output."""
    
    def __init__(self, name: str = "dotfiles", log_dir: Optional[Path] = None):
        self.name = name
        self.log_dir = log_dir or Path.home() / ".local" / "log" / "dotfiles"
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)
        
        # Clear existing handlers
        self.logger.handlers.clear()
        
        self._setup_handlers()
    
    def _setup_handlers(self):
        """Setup console and file handlers."""
        # Console handler with rich formatting
        console_handler = RichHandler(
            console=console,
            show_time=True,
            show_level=True,
            show_path=False,
            rich_tracebacks=True,
            tracebacks_show_locals=True,
        )
        console_handler.setLevel(logging.INFO)
        
        # File handler for detailed logs
        log_file = self.log_dir / f"{self.name}_{datetime.now().strftime('%Y%m%d')}.log"
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        
        # Formatters
        console_formatter = logging.Formatter("%(message)s")
        file_formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        
        console_handler.setFormatter(console_formatter)
        file_handler.setFormatter(file_formatter)
        
        self.logger.addHandler(console_handler)
        self.logger.addHandler(file_handler)
    
    def info(self, message: str, extra_data: Optional[dict] = None):
        """Log info message."""
        if extra_data:
            message = f"{message} | {extra_data}"
        self.logger.info(f"[info]{message}[/info]")
    
    def success(self, message: str, extra_data: Optional[dict] = None):
        """Log success message."""
        if extra_data:
            message = f"{message} | {extra_data}"
        self.logger.info(f"[success]✅ {message}[/success]")
    
    def warning(self, message: str, extra_data: Optional[dict] = None):
        """Log warning message."""
        if extra_data:
            message = f"{message} | {extra_data}"
        self.logger.warning(f"[warning]⚠️  {message}[/warning]")
    
    def error(self, message: str, extra_data: Optional[dict] = None):
        """Log error message."""
        if extra_data:
            message = f"{message} | {extra_data}"
        self.logger.error(f"[error]❌ {message}[/error]")
    
    def debug(self, message: str, extra_data: Optional[dict] = None):
        """Log debug message."""
        if extra_data:
            message = f"{message} | {extra_data}"
        self.logger.debug(f"[debug]🔍 {message}[/debug]")
    
    def step(self, step_name: str, total_steps: Optional[int] = None, current_step: Optional[int] = None):
        """Log a process step."""
        if total_steps and current_step:
            progress = f"({current_step}/{total_steps})"
        else:
            progress = ""
        
        self.logger.info(f"[info]🔄 {step_name} {progress}[/info]")
    
    def command_start(self, command: str, args: Optional[list] = None):
        """Log command execution start."""
        cmd_line = f"{command} {' '.join(args) if args else ''}"
        self.logger.info(f"[info]🚀 Executing: {cmd_line}[/info]")
    
    def command_success(self, command: str, output: Optional[str] = None):
        """Log successful command execution."""
        msg = f"Command completed: {command}"
        if output:
            msg += f"\nOutput: {output[:200]}..."
        self.logger.info(f"[success]{msg}[/success]")
    
    def command_error(self, command: str, error: str, exit_code: Optional[int] = None):
        """Log failed command execution."""
        msg = f"Command failed: {command}"
        if exit_code:
            msg += f" (exit code: {exit_code})"
        msg += f"\nError: {error}"
        self.logger.error(f"[error]{msg}[/error]")
    
    def installation_start(self, component: str, mode: Optional[str] = None):
        """Log installation start."""
        mode_info = f" ({mode})" if mode else ""
        self.logger.info(f"[info]📦 Installing {component}{mode_info}[/info]")
    
    def installation_success(self, component: str, duration: Optional[float] = None):
        """Log successful installation."""
        time_info = f" in {duration:.2f}s" if duration else ""
        self.logger.info(f"[success]✅ {component} installed successfully{time_info}[/success]")
    
    def installation_error(self, component: str, error: str):
        """Log installation error."""
        self.logger.error(f"[error]❌ Failed to install {component}: {error}[/error]")
    
    def backup_created(self, backup_path: Path):
        """Log backup creation."""
        self.logger.info(f"[success]💾 Backup created: {backup_path}[/success]")
    
    def config_applied(self, config_name: str, target_path: Path):
        """Log configuration application."""
        self.logger.info(f"[success]⚙️  Applied {config_name} to {target_path}[/success]")
    
    def get_log_file_path(self) -> Path:
        """Get current log file path."""
        return self.log_dir / f"{self.name}_{datetime.now().strftime('%Y%m%d')}.log"
    
    def show_log_summary(self):
        """Show summary of recent logs."""
        log_file = self.get_log_file_path()
        if log_file.exists():
            console.print(f"\n[info]📋 Log file: {log_file}[/info]")
            
            # Show last 10 lines
            with open(log_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                if lines:
                    console.print("\n[info]Recent log entries:[/info]")
                    for line in lines[-10:]:
                        console.print(f"  {line.strip()}")


# Global logger instance
logger = DotfilesLogger()


def get_logger(name: str = "dotfiles") -> DotfilesLogger:
    """Get a logger instance."""
    return DotfilesLogger(name)


if __name__ == "__main__":
    # Test the logger
    test_logger = get_logger("test")
    
    test_logger.info("This is an info message")
    test_logger.success("This is a success message")
    test_logger.warning("This is a warning message")
    test_logger.error("This is an error message")
    test_logger.debug("This is a debug message")
    
    test_logger.step("Installing packages", 5, 2)
    test_logger.command_start("apt", ["install", "git"])
    test_logger.command_success("apt install git")
    
    test_logger.installation_start("neovim", "full")
    test_logger.installation_success("neovim", 2.5)
    
    test_logger.show_log_summary()
