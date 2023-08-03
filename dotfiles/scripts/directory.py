from pathlib import Path
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


def __make_diretory__(path):
    try:
        logging.info(f"Trying to creating directory: {path}")
        Path(path).mkdir(parents=True, exist_ok=True)
    except Exception as e:
        logging.error(e)
    else:
        logging.info(f"Successfully to created directory: {path}")
    


def directory(path, directories: list[str]) -> list[str]:
    """
    Create a directory.
    
    Parameters
    ----------
    path : str
        Path to the directory.
    directories : list[str]
        List of directories.
    
    Use
    -------
    directory("~/.config", [
        
        "dir1",
         
        "dir2"
        
        ]
    )
    """
    if not isinstance(directories, list):
        raise TypeError("directories must be a list of str")
    
    for directory in directories:
        __make_diretory__(Path(path).joinpath(directory))


if __name__ == "__main__":
    directory(".", [
        "dir1",
        "dir2"
        ]
    )
    directory("./dir1/dir2/", [
        "dir1",
        "dir2"
        ]
    )
    directory("./dir2/dir1/", [
        "dir1",
        "dir2"
        ]
    )
    