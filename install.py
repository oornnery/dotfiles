import argparse
from pathlib import Path

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

from archinstall import (
    Installer,
    GfxDriver,
    SysInfo,
    disk,
    models,
    locale,
    mirrors,
    networking,
    profile,
    info,
    debug,
    run_custom_user_commands,
)
from archinstall.lib.hardware import GfxPackage
from archinstall.default_profiles.desktop import DesktopProfile
from archinstall.default_profiles.desktops.hyprland import HyprlandProfile
from archinstall.default_profiles.desktops.kde import KdeProfile


# Log various information about hardware before starting the installation. This might assist in troubleshooting
debug(f"Hardware model detected: {SysInfo.sys_vendor()} {SysInfo.product_name()}; UEFI mode: {SysInfo.has_uefi()}")
debug(f"Processor model detected: {SysInfo.cpu_model()}")
debug(f"Memory statistics: {SysInfo.mem_available()} available out of {SysInfo.mem_total()} total installed")
debug(f"Virtualization detected: {SysInfo.virtualization()}; is VM: {SysInfo.is_vm()}")
debug(f"Graphics devices detected: {SysInfo._graphics_devices().keys()}")

# For support reasons, we'll log the disk layout pre installation to match against post-installation layout
debug(f"Disk states before installing: {disk.disk_layouts()}")

# we're creating a new ext4 filesystem installation
filesystem_type = disk.FilesystemType.Btrfs
device_path = Path(var_device_path or '/dev/nvme0n1')

# get the physical disk device
device = disk.device_handler.get_device(device_path)

if not device:
	raise ValueError('No device found for given path')

# create a new modification for the specific device
device_modification = disk.DeviceModification(device, wipe=True)

# sector size of the device
sector_size = device.device_info.sector_size

# check if we're using GPT or MBR
using_gpt = SysInfo.has_uefi()
boot_partition_flags = [disk.PartitionFlag.Boot]
# configuration to GPT partition table
if using_gpt:
	start = disk.Size(1, disk.Unit.MiB, sector_size)
	size = disk.Size(1024, disk.Unit.MiB, sector_size)
	boot_partition_flags.append(disk.PartitionFlag.ESP)
else:
	start = disk.Size(3, disk.Unit.MiB, sector_size)
	size = disk.Size(203, disk.Unit.MiB, sector_size)

# boot partition
boot_partition = disk.PartitionModification(
	status=disk.ModificationStatus.Create,
	type=disk.PartitionType.Primary,
	start=start,
	length=size,
	mountpoint=Path('/boot'),
	fs_type=disk.FilesystemType.Fat32,
	flags=boot_partition_flags
)
device_modification.add_partition(boot_partition)


align_buffer = disk.Size(1, disk.Unit.MiB, sector_size)

# root partition with subvolumes
root_start = boot_partition.start + boot_partition.length
root_length = device.device_info.total_size - root_start


# create a default structure for the root partition
# Using Btrfs with subvolumes for @home, @log, @pkg and @.snapshots
# https://btrfs.wiki.kernel.org/index.php/FAQ
# https://unix.stackexchange.com/questions/246976/btrfs-subvolume-uuid-clash
# https://github.com/classy-giraffe/easy-arch/blob/main/easy-arch.sh
subvolumes = [
	disk.SubvolumeModification(Path('@'), Path('/')),
	disk.SubvolumeModification(Path('@home'), Path('/home')),
	disk.SubvolumeModification(Path('@log'), Path('/var/log')),
	disk.SubvolumeModification(Path('@pkg'), Path('/var/cache/pacman/pkg')),
	disk.SubvolumeModification(Path('@.snapshots'), Path('/.snapshots'))
]
root_partition = disk.PartitionModification(
	status=disk.ModificationStatus.Create,
	type=disk.PartitionType.Primary,
	start=root_start,
	length=root_length,
	mountpoint=None,
	fs_type=filesystem_type,
	mount_options=['compress=zstd'],
 	btrfs_subvols=subvolumes,
)

device_modification.add_partition(root_partition)

disk_config = disk.DiskLayoutConfiguration(
	config_type=disk.DiskLayoutType.Default,
	device_modifications=[device_modification]
)

# disk encryption configuration (Optional)
disk_encryption = disk.DiskEncryption(
	encryption_password=var_pass_crypt,
	encryption_type=disk.EncryptionType.Luks,
	partitions=[root_partition],
	hsm_device=None
)

# initiate file handler with the disk config and the optional disk encryption config
fs_handler = disk.FilesystemHandler(disk_config, disk_encryption)

# perform all file operations
# WARNING: this will potentially format the filesystem and delete all data
fs_handler.perform_filesystem_operations(show_countdown=False)

mountpoint = Path('/tmp')
bootloader = models.Bootloader.Systemd
kernels = [
	"linux",
	"linux-hardened",
	"linux-lts"
]
enable_testing = False
enable_multilib = True
swap = False
hostname = "archlinux"
locale_config = locale.LocaleConfiguration(
	kb_layout="us",
	sys_enc="UTF-8",
	sys_lang="en_US"
)
timezone = 'America/Sao_Paulo'
mirror_config = mirrors.MirrorConfiguration(mirror_regions={
		"Brazil": [
			"https://mirror.ufscar.br/archlinux/$repo/os/$arch",
			"http://mirror.ufscar.br/archlinux/$repo/os/$arch",
			"http://mirror.ufam.edu.br/archlinux/$repo/os/$arch",
			"http://linorg.usp.br/archlinux/$repo/os/$arch",
			"http://archlinux.c3sl.ufpr.br/$repo/os/$arch"
		]
    }
)
network_config = models.NetworkConfiguration(
	type=models.NicType.NM
)
audio_config = models.AudioConfiguration(
	audio=models.Audio.Pulseaudio
)
gfx_packages = GfxPackage.Xf86VideoAmdgpu
gfx_driver = GfxDriver.AmdOpenSource
users = [
    models.User(var_username, var_password, True),
]
# Default no profile
# 'vim',
# 'openssh',
# 'htop',
# 'wget',
# 'iwd',
# 'wireless_tools',
# 'wpa_supplicant',
# 'smartmontools',
# 'xdg-utils'
base_packages = [
	"yad", #A fork of Zenity with many improvements
   	"binutils", #A set of programs to assemble and manipulate binary and object files
	"usbutils", #USB device related utilities
	"xdg-user-dirs", #Manage user directories
	"autoconf", #A GNU tool for automatically configuring source code
	"automake", #A GNU tool for automatically creating Makefiles	
	"gcc", #The GNU Compiler Collection - C and C++ frontends
	"bison", # The GNU general-purpose parser generator
	"pkgconf", #Package compiler and linker metadata toolkit
	"which", #A utility to show the full path of commands
	"networkmanager", #Network connection manager and user applications
	"networkmanager-docs",
  	"networkmanager-openconnect", #NetworkManager VPN plugin for OpenConnect
	"networkmanager-openvpn", #NetworkManager VPN plugin for OpenVPN
	"traceroute", #A tool for displaying the route packets take to network host
	"bluez", #Daemons for the bluetooth protocol stack
	"bluez-tools", #Development and debugging utilities for the bluetooth protocol stack
	"bluez-utils", #Development and debugging utilities for the bluetooth protocol stack
	"bluez-cups",
 	"ffmpeg", #Complete solution to record, convert and stream audio and video
	"ffmpegthumbnailer", #Lightweight video thumbnailer that can be used by file managers
	"ffmpegthumbs", #Lightweight video thumbnailer that can be used by file managers
   	"playerctl", #MPRIS command-line controller and library for Spotify, MPD, and others
    "noise-suppression-for-voice", #Noise suppression for voice
    "man-db", #A utility
	"man-pages", #Linux man pages
	"dialog", #A tool to display dialog boxes from shell scripts
	"brightnessctl", #A tool to read and control device brightness
 	# Games
	"lutris", #Open Gaming Platform
	"steam", #Digital distribution platform for video games
	"wine", #Compatibility layer for running Windows applications
	"winetricks", #Script to install various redistributable runtime libraries in Wine.
	"gamemode", #Optimise system performance for games	
  	# Profile desktops
	"xdg-desktop-portal-hyprland", #Hyprland desktop portal
	"hyprlang", #Hyprland language manager
	"hyprlock", #Hyprland lock manager
	"hypridle", #Hyprland idle manager
	"hyprcursor", #Hyprland cursor manager
	"hyprpaper", #Hyprland wallpaper manager
	"waybar", #Highly customizable Wayland bar for Sway and Wlroots based compositors
	"wofi", #A launcher for wlroots-based compositors
	"pavucontrol", #PulseAudio Volume Control
	"dunst", #A lightweight replacement for the notification-daemons provided by most desktop environments
	"arandr", #A simple visual front end for XRandR\
	"lxrandr", #A simple monitor configuration tool
	"lxappearance", #A simple GTK theme switcher
 	# Development
	"jdk-openjdk", #OpenJDK Java 17 development kit
	"python-pipx", #Install and run Python applications in isolated environments
	"nodejs", #Evented I/O for V8 JavaScript
	"yarn", #Fast, reliable, and secure dependency management
	"npm", #A package manager for JavaScript
	"rust", #Systems programming language focused on safety, speed, and concurrency
	"cargo", #Rust's package manager and build system
 	# Virtualization
    "docker" # Pack, ship and run any application as a lightweight container
	"docker-compose", #Define and run multi-container applications with Docker
 	"distrobox", #A simple and lightweight development environment for Linux
	"libvirt", #API for controlling virtualization
	"virt-manager", #Desktop user interface for managing virtual machines
	"virt-install", #Desktop user interface for managing virtual machines
	"virt-firmware", #Desktop user interface for managing virtual machines
	"virt-viewer", #A lightweight interface for interacting with the graphical display of virtualized guest OS
    # Multimedia
	"vlc", #Multimedia player for various audio and video formats
	"mpv", #A free, open source, and cross-platform media player
 	"obs-studio", #Free and open source software for video recording and live streaming
	"audacity", #A program that lets you manipulate digital audio waveforms
	"blender", #A fully integrated 3D graphics creation suite
	"viewnior", #A simple, fast and elegant image viewer program	
	"gimp", #GNU Image Manipulation Program
	"feh", #A fast and light image viewer
	"celluloid", #Simple GTK+ frontend for mpv
	"kdenlive", #A non-linear video editor for GNU/Linux
	# Office
	"libreoffice-fresh", #LibreOffice Fresh is the stable version with the most recent features
	"libreoffice-fresh-pt-br", #LibreOffice Fresh Brazilian Portuguese language pack
 	# Editors
	"code", #Visual Studio Code is a code editor redefined and optimized for building and debugging modern web and cloud applications
	"obsidian", #A powerful knowledge base that works on top of a local folder of plain text Markdown files
 	# Internet
	"firefox", #Standalone web browser from mozilla.org
	"vivaldi", #A browser for our friends
	"vivaldi-ffmpeg-codecs", #Vivaldi ffmpeg codecs
	"qutebrowser", #A keyboard-driven, vim-like browser based on PyQt5
 	# Fonts
	"ttf-dejavu",
	"ttf-fira-code", 
	"ttf-hack-nerd", 
  	# Utilities
	"cmatrix", #A curses-based scrolling 'Matrix'-like screen
	"alacritty", #A cross-platform, GPU-accelerated terminal emulator
	"neovim", #Ambitious Vim-fork focused on extensibility and agility
	"wget", #A network utility to retrieve files from the Web
	"gwget", #A download manager for GNOME
 	"git", #A distributed version control system
	"github-cli", #GitHub’s official command line tool
	"ufw", #Uncomplicated and easy to use CLI tool for managing a netfilter firewall
	"gufw", #Uncomplicated and easy to use GUI tool for managing a netfilter firewall
	"htop", #Interactive process viewer
	"btop", #Resource monitor that shows usage and stats for processor, memory, disks, network and processes
	"lsd", #The next gen ls command
	"bat", #A cat(1) clone with wings
	"lolcat", #Rainbows and unicorns!
	"fd", #A simple, fast and user-friendly alternative to find
	"ripgrep", #A line-oriented search tool that recursively searches your current directory for a regex pattern
  	"zsh", #A very advanced and programmable command interpreter (shell) for UNIX
	"zsh-autosuggestions", #Fish-like autosuggestions for zsh
	"zsh-completions", #Additional completion definitions for Zsh
	"zsh-syntax-highlighting", #Fish shell like syntax highlighting for Zsh
	"starship", #The minimal, blazing-fast, and infinitely customizable prompt for any shell!
	"yadm", #Yet Another Dotfiles Manager
	"gparted", #GParted is a free partition editor for graphically managing your disk partitions
	"mc", #Midnight Commander is a text-based file manager
	"neofetch", #A fast, highly customizable system info script
]
services = [
	"bluetooth",
	"docker",
	"libvirtd",
	"ssh",
]
custom_commands = [
	"cd /home/devel; git clone https://aur.archlinux.org/paru.git",
	"chown -R devel:devel /home/devel/paru",
	"usermod -aG docker devel",
	"usermod -aG libvirt devel",
]
pipx_packages = [
	"poetry",
	"rich-cli",
	"dolphie",
	"git+https://github.com/darrenburns/elia",
	"frogmouth",
	"baca",
	"recoverpy",
	"toolong",
	"gitignore",
]

my_profile = DesktopProfile(
	current_selection=[
		KdeProfile(),
		HyprlandProfile(),
	]
)

profile_config = profile.ProfileConfiguration(
    profile=my_profile,
    gfx_driver=gfx_driver,
    gfx_packages=gfx_packages,
)


with Installer(mountpoint, disk_config, disk_encryption=disk_encryption, kernels=kernels) as installation:
	# Mount all the drives to the desired mountpoint
	if disk_config.config_type != disk.DiskLayoutType.Pre_mount:
		installation.mount_ordered_layout()

	installation.sanity_check()

	if disk_config.config_type != disk.DiskLayoutType.Pre_mount:
		if disk_encryption and disk_encryption.encryption_type != disk.EncryptionType.NoEncryption:
			# generate encryption key files for the mounted luks devices
			installation.generate_key_files()
	
	installation.set_mirrors(mirror_config)
	
	installation.minimal_installation(
		testing=enable_testing,
		multilib=enable_multilib,
     	hostname=hostname,
		locale_config=locale_config,
    )
	
	if swap:
		installation.setup_swap('zram')
	# self.pacman.strap('iwd')
	# self.enable_service('iwd')
	
	if bootloader == models.Bootloader.Grub and SysInfo.has_uefi():
		installation.add_additional_packages("grub")
	installation.add_bootloader(bootloader)

	installation.copy_iso_network_config(enable_services=True)
	
	network_config.install_network_config(installation, profile_config)
	
	installation.create_users(users)

	audio_config.install_audio_config(installation)
	
	installation.add_additional_packages(base_packages)

	installation.set_timezone(timezone)
	
	# configure ntp
	installation.activate_time_synchronization()

	profile.profile_handler.install_profile_config(installation, profile_config)

	installation.enable_service(services)

	run_custom_user_commands(custom_commands, installation)
	
	archinstall

	# install packages using pipx
	for p in pipx_packages:
		installation.run_command(f"pipx install {p}")
	installation.set_mirrors(mirror_config)

	# Optionally, install a profile of choice.
	# In this case, we install a minimal profile that is empty



