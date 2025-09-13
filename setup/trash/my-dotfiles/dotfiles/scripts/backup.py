from shutil import move, copytree


import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.FileHandler("log.log"),
        logging.StreamHandler()
        
    ]
)


def __cp_directory__(orignal_path: str, destination_path: str):
    copytree(orignal_path, destination_path)

def __mv_directory__(orignal_path: str, destination_path: str):
    move(orignal_path, destination_path)

def backup(orignal_path: str, destination_path: str = "./dotfiles/backup", action: str = "copy"):
    """
    Backup a directory by either copying or moving it to a specified destination.
    
    Parameters:
    -----------
    
    orignal_path (str): The path of the directory to be backed up.
    
    destination_path (str): The path where the directory should be backed up to. Defaults to "./dotfiles/backup".
    
    action (str): The action to perform for the backup. Options are "copy" or "move". Defaults to "copy".
    """
    
    try:
        logging.info(f"Trying to {action} directory: {orignal_path} to: {destination_path}")
        match action:
            case "copy":
                __cp_directory__(orignal_path, destination_path)
            case "move":
                __mv_directory__(orignal_path, destination_path)
    except Exception as e:
        logging.error(e)
    else:
        logging.info(f"Successfully to {action} directory: {orignal_path} to: {destination_path}")


if __name__ == "__main__":
    backup("./dir1")
    backup("./dir2")