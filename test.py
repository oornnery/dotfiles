import argparse

parser = argparse.ArgumentParser(description='Arch install script')

# Adicione os argumentos necessários
parser.add_argument('--device_path', '-dp', required=True, help='Path the device to install Arch Linux')
parser.add_argument('--username', '-u', required=True, help='Username login')
parser.add_argument('--password', '-p', required=True, help='Password login')
parser.add_argument('--pass_crypt', '-pc', required=True, help='Password to encrypt the disk')

# Parse os argumentos da linha de comando
args = parser.parse_args()

# Defina as variáveis com os argumentos
var_device_path = args.device_path
var_username = args.username
var_password = args.password
var_pass_crypt = args.pass_crypt

# Imprima as variáveis
print('Device path:', var_device_path)
print('Username:', var_username)
print('Password:', var_password)
print('Password crypt:', var_pass_crypt)
