
from dataclasses import dataclass
import subprocess
from httpx import Client
from parsel import Selector

from rich.console import Console
from rich.columns import Columns
from rich.panel import Panel
from rich.live import Live

console = Console()

@dataclass
class Package:
    repo: str
    name: str
    last_version: str
    description: str
    last_update: str
    url: str
    

def get_description(package_name: str) -> str:
    client = Client()
    response = client.get(f"https://archlinux.org/packages/?sort=&q={package_name}&maintainer=&flagged=")
    return response.text

def get_packages(package: str) -> str:
    html_text = get_description(package)
    html_selector = Selector(text=html_text)
    selector = html_selector.css("#exact-matches > table > tbody > tr > td")
    packages = [package.css("::text").get() for package in selector]
    if packages:
        arch = packages[0]
        repo = packages[1]
        name = packages[2]
        last_version = packages[3]
        description = packages[4]
        last_update = packages[5]
        url = "https://archlinux.org"+selector[2].css("::attr(href)").get()
    else:
        arch = None
        repo = None
        name = package
        last_version = None
        description = None
        last_update = None
        url = None
    
    return Package(arch, repo, name, last_version, description, last_update, url)


def consult_package(package_name: str) -> Package:
    consult = subprocess.run(
        ["pacman", "-S", "--info", package_name],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    packages = consult.stdout
    packages = packages.decode("utf-8")
    packages = packages.splitlines()
    packages = [pkg.split(':') for pkg in packages]
    packages = [pkg for pkg in packages if pkg == '                  ']
    
    
    return packages

if __name__ == "__main__":

    console.print(consult_package("mesa"))
    
    # def read_packages() -> list[str]:
    #     with open("dotfiles/packages-lists/base", "r") as f:
    #         packages = f.readlines()
    #         packages = [package.strip() for package in packages]
    #         packages = [package for package in packages if package]
    #     return [package.replace('\n', '') for package in packages]
    
    # def make_panel(package: Package) -> Panel:
    #     return Panel (
    #         f"[bold green]Arch:[/bold green] {package.arch}\n[bold green]Name:[/bold green] {package.name}\n[bold green]Description:[/bold green] {package.description}\n[bold green]Last version:[/bold green] {package.last_version}\n[bold green]Last update:[/bold green] {package.last_update}\n[bold green]Repo:[/bold green] {package.repo}\n[bold green]URL:[/bold green] {package.url}\n",
    #         title=package.name,
    #         expand=True
    #     )
    
    
    # console = Console()
        
    # with Live(screen=False, auto_refresh=False, transient=True) as live:
    #     content = []
    #     for package in read_packages():
    #         content.append(make_panel(get_packages(package)))
    #         console.clear()
    #         console.print(Columns(content))
    #     live.update(console.print(Columns(content)))
        
        
