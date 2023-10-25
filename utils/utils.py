import subprocess

def install_packages(packages: list[str], inter: str = "pacman"):
    """
    Install packages using the specified package manager.
    
    Args:
        packages (list[str]): A list of package names to install.
        inter (str, ["pacman", "paru", "yay"]): The package manager to use. Defaults to "pacman". 
    """
    def __run_command__(command: list[str]):
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
    match inter:
        case "paru":
            command = ["paru", "--noconfirm", "--needed", "-S"] + packages
        case "yay":
            command = ["yay", "--noconfirm", "--needed", "-S"] + packages
        case _:
            command = ["sudo", "pacman", "--noconfirm", "--needed", "-S"] + packages

    __run_command__(command)
    

def backup(orignal_path: str, destination_path: str = "./dotfiles/backup", action: str = "copy"):
    """
    Backup a directory by either copying or moving it to a specified destination.
    
    Args:
        orignal_path (str): The path of the directory to be backed up.
        destination_path (str): The path where the directory should be backed up to. Defaults to "./dotfiles/backup".
        action (str): The action to perform for the backup. Options are "copy" or "move". Defaults to "copy".
    """
    _orignal_path = orignal_path
    _destination_path = destination_path
    _action = action