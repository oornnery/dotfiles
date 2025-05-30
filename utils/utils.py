import platform
import subprocess
import logging
import os
from typing import Literal

from rich.logging import RichHandler
from rich.console import Console
from rich.panel import Panel

console = Console()


log = logging.getLogger("rich")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[RichHandler(rich_tracebacks=True)]
)


def detect_os():
    os_name = platform.system().lower()
    _os = 'unknown'
    log.info(f'Detected platform: {os_name}')
    if os.path.isfile('/etc/arch-release'):
        _os = 'arch'
    elif os.path.isfile('/etc/debian_version'):
        _os = 'debian'
    log.info(f"Detected OS: {_os}")
    return _os

class Pacman:
    def __init__(self):
        pass
    
    def __repr__(self):
        return "Pacman"
    
    def _run(func):
        def wrapper(*args, **kwargs):
            _cmd = func(*args, **kwargs)
            for cmd in _cmd:
                p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                if p.returncode != 0:
                    console.print(
                        Panel(p.stderr.decode("utf-8"), title="Error", border_style="red")
                    )
                console.print(
                    Panel(p.stdout.decode("utf-8"), title="Output", border_style="green")
                )
        return wrapper
    
    @classmethod
    @_run
    def install(cls, package: str, refresh: bool = True, flags: list[str] = []):
        _S = '-Sy' if refresh else '-S'
        _flags = map(lambda x: x.strip(), flags)
        yield ['pacman', _S, package, *_flags]
    
    @classmethod
    def remove(cls, package: str, recursive: bool = True, flags: list[str] = []):
        _R = '-Rs' if recursive else '-R'
        _flags = map(lambda x: x.strip(), flags)
        yield ['pacman', _R, package, *_flags]
    
    @classmethod
    def upgrade(cls):
        yield ['sudo', 'pacman', '-Syu']
    
    @classmethod
    def update_keys(cls):
        yield cls.install('archlinux-keyring', flags=['--noconfirm', '--needed'])
        # yield ['pacman-key', '--init']
        # yield ['pacman-key', '--populate', 'archlinux']
        
def install_package(package: str, os_name: Literal["arch", "debian"]) -> None:
    package.strip()
    log.info(f"Installing package: {package}")
    match os_name:
        case "arch":
            cmd = ['pacman', '-S', package]
        case "debian":
            cmd = ['apt-get', 'install', '-y', package]
        case _:
            raise ValueError(f"Unknown OS: {os_name}")
    p = subprocess.run(cmd, stdout=subprocess.PIPE)
    print(p.stdout.decode("utf-8"))

def update_packages(os_name: Literal["arch", "debian"]) -> None:
    match os_name:
        case "arch":
            cmd = ['pacman', '-Sy']
        case "debian":
            cmd = ['apt-get', 'update']
        case _:
            raise ValueError(f"Unknown OS: {os_name}")
    p = subprocess.run(cmd, stdout=subprocess.PIPE)
    print(p.stdout.decode("utf-8"))


if __name__ == "__main__":
    os_name = detect_os()
    # install_package('zsh', os_name)
    # update_packages(os_name)
    
    p = Pacman
    print(p.install('zsh'))
    print(p.remove('zsh'))
    print(p.upgrade())
    print(p.update_keys())
    
