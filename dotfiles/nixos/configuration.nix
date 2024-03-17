# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  };

  # Networking
  networking = {
    hostName = "nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };
  
  # Hardware
  hardware = {
    pulseaudio = {
      enable = false;
    };
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };
  };

  # Services
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Enable the KDE Plasma Desktop Environment.
      displayManager = {
        sddm.enable = true;
        # Enable automatic login for the user.
        autoLogin = {
          enable = true;
          user = "oornnery";
        };
 
      };
      desktopManager = {
        plasma5.enable = true;
      };
      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
      # Configure keymap in X11
      layout = "br,us";
      xkbVariant = "";
      xkbOptions = "grp:win_space_toggle";
 
    };
    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    # Bluetooth
    blueman.enable = false;
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };


  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  
  # Docker
  virtualisation.docker.enable = true;

  # Lutris 
  hardware.opengl.driSupport32Bit = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.oornnery = {
    isNormalUser = true;
    description = "oornnery";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      vivaldi
      alacritty
      qutebrowser
      thunderbird
      neofetch
      cmatrix
      yadm
      yad
      nmap
      marktext
      #obsidian
      gimp
      kdenlive
      audacity
      rofi
      wofi
      lunarvim
      lutris
      vscode
      heroic-unwrapped
      microsoft-edge
    ];
 
  };
  nix.settings.allowed-users = [ "oornnery" ];

  # flatpak
  services.flatpak.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  zsh
	vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
	neovim
	lsd
	git
	gh
	htop
	btop
	docker
	docker-compose
	unzip
	python3
	pipx
  # support both 32- and 64-bit applications
  wineWowPackages.stable
  # support 32-bit only
  wine
  # support 64-bit only
  (wine.override { wineBuild = "wine64"; })
  # support 64-bit only
  wine64
  # wine-staging (version with experimental features)
  wineWowPackages.staging
  # winetricks (all versions)
  winetricks
  # native wayland support (unstable)
  wineWowPackages.waylandFull
  jdk8
  jdk

  ventoy-full
  
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  
  # Nix flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
