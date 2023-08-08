import sys
import toml
import typing

def read_packages(line, path="packages.toml"):
    with open(f"{path}", "r") as f:
        packages = toml.load(f)
    packages = packages+line
    return packages

print("Installing packages...")
list_of_packages = sys.argv[1:]
folder = []
for package in list_of_packages:
    folder+=[[package]]
    # print(f'Installing package: "{package}"')
folder
print(folder.__class__)

#print("Installing packages: " + read_packages(folder))
