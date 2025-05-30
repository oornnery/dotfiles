import subprocess
import logging
import dataclasses


logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')


def run_command(command: str):
    """Run a command in the shell"""
    try:
        process = subprocess.Popen(
            command.split(' '), 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            universal_newlines=True
            )
        
        for stdout_line in iter(process.stdout.readline, ''):
            logging.info(stdout_line.strip())
            yield stdout_line.strip()
        
        for stderr_line in iter(process.stderr.readline, ''):
            logging.error(stderr_line.strip())
            yield stderr_line.strip()
        
        process.stdout.close()
        process.stderr.close()
        
        return_code = process.wait()
        
        if return_code != 0:
            logging.error(f"Script execution failed with return code {return_code}")
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        print(f"An error occurred: {str(e)}")
    finally:
        logging.info("Script execution completed")


def install_package(packages: list[str], package_manager: str = 'pacman', flags: list[str] = ['--needed',]):
    """Install or remove packages using pacman"""
    command = f"pacman -S {' '.join(packages)}"
    run_command(command)

def 


# Exemplo de uso
for l in execute_script("ping 8.8.8.8"):
    print(l)
