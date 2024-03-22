from typing import Literal
import subprocess
import shutil
import logging
from pathlib import Path
from rich.console import Console
from rich.prompt import Prompt
from rich.panel import Panel
from rich.logging import RichHandler


console = Console()
logging.basicConfig(
    level="NOTSET",
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler(rich_tracebacks=True, omit_repeated_times=False)]
)
log = logging.getLogger("rich")


def run(args: list[str]):
    try:
        with console.status("Running command..."):
            command = subprocess.run(args, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        log.error(f"Command error: {e}")
        return e.stderr.strip()
    else:
        log.info(f"Command executed: {command.args}")
        log.info(f"{command.stdout.strip()}")
        return command.stdout.strip()

def git_settings():
    """
    Setting global git configurations.
    """
    _username_ = "[blue]Username[/blue]"
    _email_ = "[blue]E-mail[/blue]"
    while True:
        username = Prompt.ask(_username_, console=console)
        email = Prompt.ask(_email_, console=console)
        console.print(Panel(f"{_username_}: {username}\n{_email_}: {email}"))
        ask = Prompt.ask("Is this information correct?", choices=["y", "n"])
        if ask.lower() == "y":
            break
    command = ["git", "config", "--global"]
    log.info(f"Setting git username {username}")
    run(command + ["user.name", username])
    log.info(f"Setting git E-mail {email}")
    run(command + ["user.email", email])

def install_aur(package_manager: Literal["paru", "yay"] = "paru"):
    """
    install aur package manager
    """
    if package_manager == "paru":
        url = "https://aur.archlinux.org/paru.git"
    elif package_manager == "yay":
        url = "https://aur.archlinux.org/yay.git"
    else:
        raise ValueError("Invalid package manager.")
    install_packages(["git", "base-devel"], flags=["--noconfirm", "--needed"])
    command = ["cd", "git", "clone", url, "cd", package_manager, "&&", "makepkg", "-si"]
    run(command)

def install_packages(packages: list[str], package_manager: Literal["pacman", "paru", "yay"] = "pacman", flags: list[str] = []):
    """
    Install packages using the specified package manager.
    """ 
    try:
        command = [package_manager, "-S", *flags, *packages]
        result = run(command)
    except subprocess.CalledProcessError as e:
        log.error(f"Error: {e}")
    except FileNotFoundError:
        log.error(f"Error: {package_manager} not found.")
        install_aur(package_manager)
    else:
        log.info(f"{result}")
        log.info(f"Installed packages: {packages}")

def move(name: str, origin_path: str, destination_path: str, backup: bool = True, is_dir: bool = False):
    _origin_path_ = Path(origin_path) / name
    _destination_path_ = Path(destination_path) / name
    _backup_ = Path('.bak') / name

    try:
        if _origin_path_.exists():
            if backup and _destination_path_.exists():
                shutil.copy2(_destination_path_, _backup_)
                log.info(f"File '{_destination_path_.name}' moved from '{_origin_path_}' to '{_backup_}'.")
            shutil.copy2(_origin_path_, _destination_path_)
            log.info(f"File '{_origin_path_}' moved to '{_destination_path_}'.")
    except FileNotFoundError as e:
        log.error(f"File not found: {e}")
        return False
    except Exception as e:
        log.error(f"Error: {e}")
        return False
    else:
        return True


if __name__ == "__main__":

    # git_settings()
    move("test.txt", "./test", "~/test")
