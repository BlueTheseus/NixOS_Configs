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
	HOSTNAME = "Altar";
	HOSTID = ""; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "";
	TIMEZONE = "America/Los_Angeles";
	unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in {
	imports = [
		../modules/Core.nix
		../modules/Desktops/kde-plasma.nix
		#../modules/Desktops/cosmic.nix
	];

	# ----- BOOT -----
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
		#kernelPackages = pkgs.linuxPackages_6_17;
		supportedFilesystems = [ "zfs" ]; # Optionally add ntfs
		zfs.forceImportRoot = false;
	};

	# ----- LOCALISATION -----
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

	# ----- USERS -----
	users.users."${USER}" = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
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
			enable = true;
			allowReboot = true;
			dates = "Saturday 02:30 ${TIMEZONE}";
		};
	};
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			allowed-users = [ "@wheel" ];
			#max-jobs = 4; # Tuned for background updates while running on battery.
			#cores = 2;    # These can be changed with appropriate option flags.
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
	#services.libinput.enable = true;

	# ----- PRINTING -----
	# Enable CUPS to print documents.
	services.printing.enable = true;

	# ----- DOCUMENTATION -----
	documentation = {
		dev.enable = true;
		man = {
			#man-db.enable = false; # Use mandoc instead of man-db
			#mandoc.enable = true;
			cache.enable = true;
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
	nixpkgs.config = {
		allowUnfree = true;
		packageOverrides = pkgs: {
			unstable = import unstableTarball {
				config = config.nixpkgs.config;
			};
		};
	};
	environment.systemPackages = with pkgs; [
		# ~ System ~
		cpulimit #................. archived, use limitcpu -- however only this works to successfully limit children processes
		usbutils #................. Tools for working with USB devices, such as lsusb

		# ~ Info ~
		exiftool #................. file metadata
		fastfetch
		mediainfo

		# ~ Networking ~
		bluez #.................... Official linux bluetooth protocol stack
		cifs-utils #............... Samba
		curl
		dnsutils
		#mosh #..................... Mobile shell (ssh replacement)
		#openssl
		syncthing
		wget
		yt-dlp

		# ~ Utilities ~
		bat #...................... pretty cat for the terminal
		cbonsai #.................. screensaver
		ffmpeg
		fzf
		glow #......................................... cli markdown renderer
		ifuse
		libimobiledevice #......... IOS device connection
		libnotify #................ notify-send
		libsixel #................. SIXEL library for console graphics, and converter programs
		p7zip #.................... zip utility
		rclone #................... Like rsync but for cloud storage services
		rsync
		trash-cli #................ trash can for the commandline. Don't accidentally rm something important ;)
		unipicker #................ CLI utility for searching unicode characters by description and optionally copying them to clipboard
		zbar #..................... Bar code reader (including QR code)

		# ~ Languages ~
		#julia-bin #................ Julia programming language binary
		#octaveFull
		python313 #.................................... Python 3.13
		python313Packages.numpy
		#python313Packages.matplotlib
		#texliveFull
		#texliveMedium
		texliveBasic
		#texliveSmall
		#texliveMinimal
		typst

		# ~ Productivity ~
		lf #....................... file manager
		tmux #..................... widely-used terminal multiplexer
		#w3m #...................... Text-mode web browser

		# ~ Desktop ~
		#anki #..................... flashcards
		#arduino #................. arduino IDE
		#aseprite #................ pixelart and animation editor
		#audacity #................ Sound editor with graphical UI
		#blender #................. 3d modeling
		calibre #...................................... Comprehensive e-book software
		unstable.brave #.................... browser
		discord
		firefox #.................. browser -- backup for when brave won't properly render websites
		foot #..................... wayland terminal
		kdePackages.kcharselect #.. Tool to select and copy special characters from all installed fonts
		#kicad #.................... open source electronics design automation suite
		libnotify #................ a library that sends desktop notifications to a notification daemon
		libreoffice
		#ltspice
		#kdePackages.merkuro #..... Merkuro is an application suite designed to make handling your emails, calendar, contacts, and tasks simple.
		mpv #...................... video and music player
		obsidian #................. notes
		obs-studio
		prismlauncher #............ Minecraft Launcher
		#protontricks #.............
		unstable.telegram-desktop
		#texstudio #............... TeX and LaTeX editor
		tofi #..................... Tiny dynamic menu for Wayland
		typstwriter #.............. Editor for the typst formatting language
		vlc #...................... media player
		zathura #.................. pdf/epub viewer
	];


	# ----- GAMING -----
	# https://nixos.wiki/wiki/Steam
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
}
