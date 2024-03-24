import argparse
from pathlib import Path

from archinstall import Installer
from archinstall import profile
from archinstall.default_profiles.minimal import MinimalProfile
from archinstall.default_profiles.desktops.kde import KdeProfile
from archinstall.default_profiles.desktops.hyprland import HyprlandProfile
from archinstall.default_profiles.desktops.qtile import QtileProfile
from archinstall import disk
from archinstall import models
from archinstall.lib.locale import LocaleConfiguration
from archinstall.lib.models import Bootloader
from archinstall.lib.mirrors import MirrorConfiguration

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


# we're creating a new ext4 filesystem installation
fs_type = disk.FilesystemType('btrfs')
device_path = Path(var_device_path or '/dev/nvme0n1')

# get the physical disk device
device = disk.device_handler.get_device(device_path)

if not device:
	raise ValueError('No device found for given path')

# create a new modification for the specific device
device_modification = disk.DeviceModification(device, wipe=True)


# create a new boot partition
boot_partition = disk.PartitionModification(
	status=disk.ModificationStatus.Create,
	type=disk.PartitionType.Primary,
	start=disk.Size(1, disk.Unit.MiB, device.device_info.sector_size),
	length=disk.Size(1024, disk.Unit.MiB, device.device_info.sector_size),
	fs_type=disk.FilesystemType.Fat32,
	mountpoint=Path('/boot'),
	flags=[disk.PartitionFlag.Boot, disk.PartitionFlag.ESP],
)
device_modification.add_partition(boot_partition)

start_root = boot_partition.length
length_root = device.device_info.total_size - start_root

# create a new root partition
root_partition = disk.PartitionModification(
	status=disk.ModificationStatus.Create,
	type=disk.PartitionType.Primary,	
	start=start_root,
	length=length_root,
	fs_type=fs_type,
	mountpoint=Path('/'),
	mount_options=["compress=zstd"],
	btrfs_subvols=[
		disk.device_model.SubvolumeModification(
			name='@home',
			mountpoint=Path('/home'),
			compress=False,
			nodatacow=False,
		),
		disk.device_model.SubvolumeModification(
			name='@log',
			mountpoint=Path('/var/log'),
			compress=False,
			nodatacow=False,
		),
		disk.device_model.SubvolumeModification(
			name='@pkg',
			mountpoint=Path('/var/cache/pacman/pkg'),
			compress=False,
			nodatacow=False,
		),
		disk.device_model.SubvolumeModification(
			name='@.snapshots',
			mountpoint=Path('/.snapshots'),
			compress=False,
			nodatacow=False,
		),
	]
	
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
locale_config = LocaleConfiguration(
	kb_layout="us",
	sys_enc="UTF-8",
	sys_lang="en_US"
)
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
	"ethtool", #Utility for controlling network drivers and hardware	
	"wpa_supplicant", #A utility providing key negotiation for WPA wireless networks
	"iw", #nl80211 based CLI configuration utility for wireless devices
 	"iwd", #Internet Wireless Daemon
	"networkmanager", #Network connection manager and user applications
	"network-manager-applet", #Applet for managing network connections
	"networkmanager-docs", #Network connection manager and user applications (API documentation)
	"networkmanager-openconnect", #NetworkManager VPN plugin for OpenConnect
	"networkmanager-openvpn", #NetworkManager VPN plugin for OpenVPN
	"openssh", #Premier connectivity tool for remote login with the SSH protocol
	"dhclient", #A DHCP client
	"traceroute", #A tool for displaying the route packets take to network host
	"ntp", #Network Time Protocol reference implementation
	"bluez", #Daemons for the bluetooth protocol stack
	"bluez-utils", #Development and debugging utilities for the bluetooth protocol stack
 	"alsa-plugins", #Additional ALSA plugins
	"alsa-utils", #An alternative implementation of Linux sound support
	"pulseaudio", #A featureful, general-purpose sound server
	"pulseaudio-alsa", #ALSA Configuration for PulseAudio
	"pulseaudio-bluetooth", #Bluetooth support for PulseAudio
    "pamixer", #Pulseaudio command-line mixer
	"ffmpeg", #Complete solution to record, convert and stream audio and video
	"ffmpegthumbnailer", #Lightweight video thumbnailer that can be used by file managers
   	"playerctl", #MPRIS command-line controller and library for Spotify, MPD, and others
    "noise-suppression-for-voice", #Noise suppression for voice
    "man-db", #A utility
	"man-pages", #Linux man pages
	"bridge-utils", #Utilities for configuring the Linux Ethernet bridge
	"btrfs-progs", #Btrfs filesystem utilities
	"cups", #The CUPS Printing System
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
	"virt-viewer", #A lightweight interface for interacting with the graphical display of virtualized guest OS
	"qemu", #A generic and open source machine emulator and virtualizer
    # Multimedia
	"vlc", #Multimedia player for various audio and video formats
	"mpv", #A free, open source, and cross-platform media player
 	"obs-studio", #Free and open source software for video recording and live streaming
	"audacity", #A program that lets you manipulate digital audio waveforms
	"blender", #A fully integrated 3D graphics creation suite
	"viewnior", #A simple, fast and elegant image viewer program	
	"gimp", #GNU Image Manipulation Program
	"simplescreenrecorder", #A feature-rich screen recorder that supports X11 and OpenGL
	"feh", #A fast and light image viewer
	"celluloid", #Simple GTK+ frontend for mpv
	"kdenlive", #A non-linear video editor for GNU/Linux
	# Office
	"libreoffice-fresh", #LibreOffice Fresh is the stable version with the most recent features
	"libreoffice-fresh-pt-br", #LibreOffice Fresh Brazilian Portuguese language pack
 	# Editors
	"marktext", #A simple and elegant markdown editor
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
bootloader = Bootloader.Systemd	
timezone = 'America/Sao_Paulo'
mirror_config = MirrorConfiguration(mirror_regions={
		"Brazil": [
			"https://mirror.ufscar.br/archlinux/$repo/os/$arch",
			"http://mirror.ufscar.br/archlinux/$repo/os/$arch",
			"http://mirror.ufam.edu.br/archlinux/$repo/os/$arch",
			"http://linorg.usp.br/archlinux/$repo/os/$arch",
			"http://archlinux.c3sl.ufpr.br/$repo/os/$arch"
		]
    }
)
services = [
	"NetworkManager",
	"bluetooth",
	"docker",
	"libvirtd",
	"ntp",
	"ssh",
 	"iwd",
]
custom_command = [
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


with Installer(
	mountpoint,
	disk_config,
	disk_encryption=disk_encryption,
	kernels=[
        "linux",
        "linux-hardened",
        "linux-lts"
    ]
) as installation:
	installation.mount_ordered_layout()
	installation.minimal_installation(
		multilib=True,
     	hostname='archlinux',
		locale_config=locale_config,
    )
	installation.pacman.run(['--noconfirm', '-S'] + base_packages)
	# self.pacman.strap('iwd')
	# self.enable_service('iwd')
	installation.add_bootloader(bootloader)
	installation.set_timezone(timezone)
	installation.set_keyboard_language(locale_config)
	installation.enable_service(services)
	for c in custom_command:
		installation.run_command(c)
	# install packages using pipx
	for p in pipx_packages:
		installation.run_command(f"pipx install {p}")
	installation.copy_iso_network_config(enable_services=True)
	installation.set_mirrors(mirror_config)

# Optionally, install a profile of choice.
# In this case, we install a minimal profile that is empty
profile_config = profile.ProfileConfiguration(MinimalProfile())
kde_profile = profile.ProfileConfiguration(KdeProfile())
hyprland_profile = profile.ProfileConfiguration(HyprlandProfile())
profile.profile_handler.install_profile_config(installation, profile_config)
profile.profile_handler.install_profile_config(installation, kde_profile)
profile.profile_handler.install_profile_config(installation, hyprland_profile)


user = models.User(var_username, var_password, True)
installation.create_users(user)

