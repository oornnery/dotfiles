import subprocess
import shutil
import logging
from pathlib import Path

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
    


def configurar_logger():
    # Configura o logger
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s',
                        filename='copiar_mover.log',
                        filemode='a')
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)


log = logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s',
                        filename='copiar_mover.log',
                        filemode='a')
def copiar_e_mover(file: str, origin_path: str, destination_path: str, backup: bool = True):
    origin = Path(origin_path)
    destination = Path(destination_path)
    backup = Path('.bak')

    try:
        file_original_path = Path(destination_path+file)
        # Execulta o backup do arquivo original
        if file_original_path.exists() and backup:
            shutil.move(file_original_path, backup)
            log.info(f"File '{file_original_path.name}' moved from '{origin}' to '{backup}'.")
        
        # Copia o arquivo para o destino
        shutil.copy2(origin, destination)
        log.info(f"Arquivo copiado de '{origin}' para '{destination}'.")

        log.info(f"Arquivo original movido de '{origin}' para '{backup}'.")
    except FileNotFoundError:
        log.error(f"Erro: O arquivo de origem '{origin}' não existe.")
        return False
    except Exception as e:
        log.error(f"Erro: {e}")
        return False

    return True

if __name__ == "__main__":
    configurar_logger()

    # Exemplo de uso
    origem = "/caminho/para/arquivo.txt"
    destino = "/caminho/para/destino/arquivo.txt"
    backup = "/caminho/para/backup"

    copiar_e_mover(origem=origem, destino=destino, backup=backup)
