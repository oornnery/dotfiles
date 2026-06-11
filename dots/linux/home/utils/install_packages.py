import subprocess



def __run_command__(command: str):
    try:
        subprocess.run(command, check=True)
        print("Pacotes instalados com sucesso!")
    
    except subprocess.CalledProcessError as e:
        print(f"Erro ao instalar pacotes: {e}")
    
    except FileNotFoundError:
        if command == "paru":
            print("Install paru")
        elif command == "yay":
            print("Install yay")


def install_packages(packages: list[str], inter: str = "pacman"):
    """
    Install packages using the specified package manager.
    
    Args:
        packages (list[str]): A list of package names to install.
        inter (str, ["pacman", "paru", "yay"]): The package manager to use. Defaults to "pacman". 
    
    Raises:
        None
    
    Returns:
        None
    """
    match inter:
        case "pacman":
            command = ["sudo", "pacman", "--noconfirm", "--needed", "-S"] + packages
        case "paru":
            command = ["paru", "--noconfirm", "--needed", "-S"] + packages
        case "yay":
            command = ["yay", "--noconfirm", "--needed", "-S"] + packages
    __run_command__(command)
        
if __name__ == "__main__":
    install_packages(['cmatrix', 'github-cli'], inter='paru')