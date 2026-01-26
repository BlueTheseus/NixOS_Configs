# - variables
# 	- hostname
# 	- hostID
# - imports
# - boot
# - users

# Filesystem Recommendations:
# 	- BTRFS
# 	- Separate root and home partitions
# Swap:
# 	- Recommended size: (amount of RAM) + sqrt(amount of RAM)
{ config, pkgs, lib, ... }:
let
	HOSTNAME = "";
	HOSTID = ""; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "";
	TIMEZONE = "America/Los_Angeles";
in {
	imports = [
		#../hardware/
		../modules/Core.nix
		#../modules/Desktops/kde-plasma.nix
	];

	# ----- BOOT -----
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
		# Optionally use a different kernel:
		#kernelPackages = pkgs.linuxPackages_latest_hardened;
		supportedFilesystems = [ "zfs" ]; # Optionally add ntfs
		zfs.forceImportRoot = false;
	};
	specialisation = {
		CopyToRAM.configuration = {
			system.nixos.tags = [ "Copy_To_RAM" ];
			boot.kernelParams = [ "copytoram" ];
		};
	};

	# ----- LOCALISATION AND CONSOLE -----
	time.timeZone = "${TIMEZONE}";
	
	# ----- NETWORKING -----
	networking = {
		hostName = "${HOSTNAME}";
		hostId = "${HOSTID}"; # for zfs. generated with: head -c4 /dev/urandom | od -A none -t x4
	};
	hardware.bluetooth = { # https://mynixos.com/nixpkgs/option/hardware.bluetooth.settings
		enable = true;
		settings.General = {
			#ControllerMode = "bredr"; # Possible values: dual, bredr, le
			Enable = "Source,Sink,Media,Socket";
		};
	};
	# ~ Samba ~
	# https://nixos.wiki/wiki/Samba
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk/portals/samba         755 root users" #.... for samba shares and the like -- portals to other places
		"d /dsk/portals/samba/Private 755 root users" #.... for samba shares and the like -- portals to other places
	];
	# /etc/nixos/secrets/samba
	# username=<USERNAME>
	# domain=<DOMAIN> # (optional)
	# password=<PASSWORD>
	fileSystems."/dsk/portals/samba/Private" = {
		device = "//hostname/Private";
		fsType = "cifs";
		options = let
			# this line prevents hanging on network split
			automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=/etc/nixos/secrets/samba"];
	};

	# ----- USERS -----
	users.users."${USER}" = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" "video" ];
		openssh.authorizedKeys.keyFiles = [
			/home/${USER}/.ssh/authorized_keys/key.pub
		];
	};
	
	# ----- SYSTEM -----
	security = {
		sudo.enable = false;
		doas = {
			enable = true;
			extraRules = [{
				users = [ "${USER}" ];
				keepEnv = true;
				persist = true;
			}];
		};
	};
	system = {
		copySystemConfiguration = true;
		autoUpgrade = {
			enable = false;
			allowReboot = true;
			dates = "Saturday 01:30 ${TIMEZONE}";
		};
	};
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			allowed-users = [ "@wheel" ];
		};
		gc = {
			automatic = false;
			dates = "Saturday 04:00 ${TIMEZONE}";
			options = "--delete-older-than 30d";
		};
		# Auto-garbage collect when less than a certain amount of free space available
		extraOptions = ''
			min-free = ${toString (512 * 1024 * 1024)}
		'';
	};
	services.usbmuxd = { # IOS device connectivity
		enable = true;
		#package = pkgs.usbmuxd2;
	};

	# ----- SOUND -----
	# ~ ALSA ~
	#sound.enable = false;
	services.pulseaudio.enable = false;
	# ~ Pipewire ~
	#security.rkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};

	# ----- TOUCHPAD -----
	# Enable touchpad support (enabled default in most desktopManager).
	services.libinput.enable = true;

	# ----- PRINTING -----
	# Enable CUPS to print documents.
	services.printing.enable = true;

	# ----- DOCUMENTATION -----
	documentation = {
		dev.enable = true;
		man = {
			#man-db.enable = false; # Use mandoc instead of man-db
			#mandoc.enable = true;
			generateCaches = true;
		};
	};

	# ----- NIX USER REPOSITORY -----
	# https://github.com/nix-community/NUR
	nixpkgs.config.packageOverrides = pkgs: {
		nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz")
		{
			inherit pkgs;
		};
	};

	# ----- EXTRA FONTS -----
	fonts.packages = with pkgs; [
		google-fonts #...... Font files available from Google Fonts
		noto-fonts #........ Beautiful and free fonts for many languages
		nerd-fonts._0xproto
		nerd-fonts.adwaita-mono
		nerd-fonts.blex-mono
		nerd-fonts.comic-shanns-mono
		nerd-fonts.im-writing
		nerd-fonts.intone-mono
		nerd-fonts.iosevka
		nerd-fonts.iosevka-term
	];

	# ----- EXTRA SYSTEM PACKAGES -----
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		# ~ System ~
		auto-cpufreq #................................. auto cpu speed & power optimizer
		busybox #...................................... Tiny versions of common UNIX utilities in a single small executable
		clang #........................................ A C language family frontend for LLVM (wrapper script)
		cpulimit #..................................... archived, use limitcpu -- however only this works to successfully limit children processes
		libclang #..................................... A C langauge family frontend for LLVM -- provides clang and clang++
		libgcc #....................................... GNU Compiler Collection
		libuuid #...................................... A set of system utilities for Linux (util-linux-minimal)
		limitcpu
		toybox #....................................... Lightweight implementation of some Unix command line utilities
		usbutils #..................................... Tools for working with USB devices, such as lsusb

		# ~ Encryption ~
		gpg-tui #...................................... Terminal user interface for GnuPG

		# ~ Info ~
		bunnyfetch
		exiftool #..................................... file metadata
		fastfetch
		mediainfo
		starfetch
		uwufetch

		# ~ Networking ~
		bluez #........................................ Official linux bluetooth protocol stack
		cifs-utils #................................... Samba
		curl
		dnsutils
		mosh #......................................... Mobile shell (ssh replacement)
		wget
		yt-dlp

		# ~ Utilities ~
		bat #.......................................... pretty cat for the terminal
		bc #........................................... Basic Calculator
		borgbackup #................................... Deduplicating archiver with compression and encryption
		cbonsai #...................................... screensaver
		cope #......................................... A colourful wrapper for terminal programs
		ffmpeg
		findutils #.................................... GNU Find Utilities, the basic directory searching utilities of the GNU operating system -- provides: locate, updatedb
		fzf
		glow #......................................... cli markdown renderer
		ifuse
		lazygit #...................................... TUI git
		libimobiledevice #............................. IOS device connection
		libnotify #.................................... notify-send
		libsixel #..................................... SIXEL library for console graphics, and converter programs
		lz4 #.......................................... Extremely fast compression algorithm
		mtm #.......................................... Perhaps the smallest useful terminal multiplexer in the world
		nemu #......................................... Ncurses UI for QEMU
		outils #....................................... Port of OpenBSD-exclusive tools -- included for md5
		p7zip #........................................ zip utility
		pistol #....................................... file previewer
		plocate #...................................... Much faster locate
		qemu #......................................... Generic and open source machine emulator and virtualizer
		rclone #....................................... Like rsync but for cloud storage services
		restic #....................................... A backup program that is fast, efficient, and secure
		rmlint
		rsync
		trash-cli #.................................... trash can for the commandline. Don't accidentally rm something important ;)
		unipicker #.................................... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		ventoy #....................................... live-usb
		zbar #......................................... Bar code reader (including QR code)
		zstd #......................................... Zstandard real-time compression algorithm

		# ~ Languages ~
		julia #........................................ Julia programming language compiled
		julia-bin #.................................... Julia programming language binary
		octave #....................................... GNU Octave
		octaveFull
		python313 #.................................... Python 3.13
		python313Packages.numpy
		python313Packages.matplotlib
		python313Packages.scipy
		texliveFull
		typst

		# ~ Productivity ~
		abduco #....................................... Allows programs to be run independently from its controlling terminal
		aerc #......................................... Email client for your terminal
		dvtm #......................................... Dynamic virtual terminal manager
		gnuplot #......................................
		lf #........................................... file manager
		neomutt #...................................... Small but very powerful text-based mail client
		nnn #.......................................... minimal file manager
		tmux #......................................... widely-used terminal multiplexer
		vscodium #..................................... Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing)
		vscodium-fhs #................................. Wrapped variant of vscodium which launches in a FHS compatible environment. Should allow for easy usage of extensions without nix-specific modifications.
		w3m #.......................................... Text-mode web browser
		xplr #......................................... Hackable, minimal, fast TUI file explore
		zellij #....................................... user-friendly terminal multiplexer

		# ~ Desktop ~
		anki #......................................... flashcards
		arduino #...................................... arduino IDE
		aseprite #..................................... pixelart and animation editor
		audacity #..................................... Sound editor with graphical UI
		blender #...................................... 3d modeling
		bluez #........................................ official linux bluetooth protocol stack
		brave #........................................ browser
		discord
		firefox #...................................... browser -- backup for when brave won't properly render websites
		flatpak
		floorp #....................................... firefox-based browser
		foot #......................................... wayland terminal
		freecad
		freecad-wayland #.............................. General purpose Open Source 3D CAD/MCAD/CAx/CAE/PLM modeler
		freecad-qt6
		gimp #......................................... GNU Image Manipulation Program
		jellyfin-media-player
		kdePackages.kcharselect #...................... Tool to select and copy special characters from all installed fonts
		kdePackages.kdenlive #......................... Free and open source video editor, based on MLT Framework and KDE Frameworks
		kicad #........................................ open source electronics design automation suite
		libnotify #.................................... a library that sends desktop notifications to a notification daemon
		librecad #..................................... 2D CAD package based on Qt
		libreoffice
		logisim-evolution #............................ Digital logic designer and simulator
		materialgram #................................. Alternate Telegram client with material theme
		mpv #.......................................... video and music player
		obsidian #..................................... notes
		obs-studio
		protonvpn-gui
		qucs-s #....................................... Analog and Digital circuit simulator
		slack
		telegram-desktop
		tg #........................................... terminal client for telegram
		(tic-80.override { withPro = true; } ) #....... Fantasy game console
		thunderbird #.................................. email client
		tofi #......................................... Tiny dynamic menu for Wayland
		tor-browser-bundle-bin
		typstwriter #.................................. Editor for the typst formatting language
		virtualbox #................................... virtual machines
		vlc #.......................................... media player
		wezterm #...................................... terminal emulator
		zathura #...................................... pdf/epub viewer

		# ~ Nix Users Repository ~
		#nur.repos.andreasrid.stm32cubeide #............ CubeIDE for STM32
	];

	# ----- GAMING -----
	# https://nixos.wiki/wiki/Steam
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"prismlauncher" #.............................. Minecraft Launcher
		protontricks
		protonup-qt #.................................. Install and manage Proton-GE and Luxtorpeda for Steam and Wine-GE for Lutris with this graphical user interface
		(retroarch.override {
			cores = with libretro; [
				melonds
				mgba
			];
		})
		"steam"
		"steam-original"
		"steam-run"
	];
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};

	# ----- VIRTUALBOX -----
	virtualisation.virtualbox = {
		host = {
			enable = true;
			enableExtensionPack = false; # Enabling this results in compiling from source, which is slow and resource-intensive
		};
		#guest = {
			#enable = true;
			#dragAndDrop = true;
		#};
	};
	users.extraGroups.vboxusers.members = [ "${USER}" ];
	boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # temp fix: https://discourse.nixos.org/t/issue-with-virtualbox-in-24-11/57607
}
