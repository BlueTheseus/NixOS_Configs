# Build without flakes:
# 	nix build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=ISO.nix
#
# Build without flakes | nixos-generators:
# 	nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./ISO.nix -o NIXOS-custom-$(date +%Y%m%d).iso"
#
# Switch to a specialisation:
# 	nixos-rebuild switch --specialisation [SPECIALISATION_NAME]

# ----- To Do -----
# - SSH: disable password authentication, use ssh keys only
# 	- add ssh public key

{ pkgs, modulesPath, lib, ... }:
let
	ARCHITECTURE = "x86_64-linux";
	HOSTNAME = "Nomad";
	HOSTID = "bc921301";
	USER = "nomad";
in {
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
		../modules/Core.nix
		../modules/ssh.nix
	];

	nixpkgs.hostPlatform = "${ARCHITECTURE}";

	# ----- SPECIALISATIONS -----
	specialisation = {
		CopyToRAM.configuration = {
			system.nixos.tags = [ "Copy_To_RAM" ];
			boot.kernelParams = [ "copytoram" ];
		};
		KDEdesktop.configuration = {
			system.nixos.tags = [ "KDE_Desktop" ];
			imports = [ ../modules/Desktops/kde-plasma.nix ];
		};
	};

	# ----- NIX SETTINGS -----
	# Faster compression in exchange for larger file size:
	#isoImage.squashfsCompression = "gzip -Xcompression-level 1";

	# ----- NETWORKING -----
	networking = {
		hostName = "${HOSTNAME}";
		#hostId = "${HOSTID}"; # for zfs -- generated with: head -c4 /dev/urandom | od -A none -t x4
		wireless.enable = false; # Enables networking support via wpa_supplicant
		#interfaces.eth0.ipv4.addresses = [{
			#address = "10.0.0.5";
			#prefixLength = 24;
		#}];
		#defaultGateway = "10.0.0.5";
		#nameservers = [ "8.8.8.8" ];
	};
	hardware.bluetooth = {
		enable = true;
		settings.General = {
			Enable = "Source,Sink,Media,Socket";
		};
	};

	# ----- BOOT -----
	boot = {
		supportedFilesystems = [ "zfs" "ntfs" ];
		zfs.forceImportRoot = false;
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
	nix.settings.allowed-users = [ "@wheel" ];

	# ----- USERS -----
	users = lib.mkDefault {
		#motdFile = "";
		users."${USER}" = {
			isNormalUser = true;
			extraGroups = [ "networkmanager" "wheel" "video" ];
			initialPassword = "changeme";
			#openssh.authorizedKeys.keyFiles = [
				#../extras/key.pub
			#];
		};
	};

	# ----- SERVICES -----
	services.usbmuxd.enable = true; # IOS device connectivity

	# ----- SOUND -----
	# ~ ALSA ~
	services.pulseaudio.enable = false;
	# ~ Pipewire ~
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

	# ----- FONTS -----
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
		# ~ Toolbox ~
		testdisk #..................................... Data recovery utilities

		# ~ System ~
		#auto-cpufreq #................................ auto cpu speed & power optimizer
		#busybox #..................................... Tiny versions of common UNIX utilities in a single small executable
		#cgdisk
		#clang #....................................... A C language family frontend for LLVM (wrapper script)
		cpulimit #..................................... archived, use limitcpu -- however only this works to successfully limit children processes
		#libclang #.................................... A C langauge family frontend for LLVM -- provides clang and clang++
		#libgcc #...................................... GNU Compiler Collection
		#libuuid #..................................... A set of system utilities for Linux (util-linux-minimal)
		#limitcpu
		#toybox #...................................... Lightweight implementation of some Unix command line utilities
		usbutils #..................................... Tools for working with USB devices, such as lsusb

		# ~ Documentation ~
		man-pages #.................................... Linux Man-Pages Project -- a set of documentation of the Linux programming API -- check section 3
		man-pages-posix

		# ~ Encryption ~
		#gpg-tui #..................................... Terminal user interface for GnuPG

		# ~ Info ~
		#bunnyfetch
		exiftool #..................................... file metadata
		fastfetch
		mediainfo
		#neofetch
		#starfetch
		#uwufetch

		# ~ Networking ~
		bluez #........................................ Official linux bluetooth protocol stack
		cifs-utils #................................... Samba
		curl
		dnsutils
		mosh #......................................... Mobile shell (ssh replacement)
		openssh
		wget
		yt-dlp

		# ~ Utilities ~
		bat #.......................................... pretty cat for the terminal
		bc #........................................... Basic Calculator
		#borgbackup #.................................. Deduplicating archiver with compression and encryption
		cbonsai #...................................... screensaver
		#cope #........................................ A colourful wrapper for terminal programs
		#disko
		ffmpeg
		fzf
		#glow #........................................ cli markdown renderer
		ifuse
		#lazygit #..................................... TUI git
		libimobiledevice #............................. IOS device connection
		libnotify #.................................... notify-send
		libsixel #..................................... SIXEL library for console graphics, and converter programs
		#lz4 #......................................... Extremely fast compression algorithm
		#mtm #......................................... Perhaps the smallest useful terminal multiplexer in the world
		p7zip #........................................ zip utility
		#parted
		#pistol #...................................... file previewer
		#qemu #........................................ Generic and open source machine emulator and virtualizer
		rclone #....................................... Like rsync but for cloud storage services
		#restic #...................................... A backup program that is fast, efficient, and secure
		rsync
		trash-cli #.................................... trash can for the commandline. Don't accidentally rm something important ;)
		unipicker #.................................... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		#ventoy #...................................... live-usb
		#zstd #........................................ Zstandard real-time compression algorithm

		# ~ Productivity ~
		#abduco #...................................... Allows programs to be run independently from its controlling terminal
		#aerc #........................................ Email client for your terminal
		#dvtm #........................................ Dynamic virtual terminal manager
		gnuplot #......................................
		lf #........................................... file manager
		#neomutt #..................................... Small but very powerful text-based mail client
		#nnn #......................................... minimal file manager
		tmux #......................................... widely-used terminal multiplexer
		w3m #.......................................... Text-mode web browser
		#xplr #........................................ Hackable, minimal, fast TUI file explore
		#zellij #...................................... user-friendly terminal multiplexer

		# ~ Desktop ~
		#anki #........................................ flashcards
		#arduino #..................................... arduino IDE
		#aseprite #.................................... pixelart and animation editor
		#audacity #.................................... Sound editor with graphical UI
		#blender #..................................... 3d modeling
		#bluez #....................................... official linux bluetooth protocol stack
		brave #........................................ browser
		#discord
		#firefox #..................................... browser
		#flatpak
		#floorp #...................................... firefox-based browser
		foot #......................................... wayland terminal
		#freecad
		#freecad-wayland #............................. General purpose Open Source 3D CAD/MCAD/CAx/CAE/PLM modeler
		#freecad-qt6
		#gimp #........................................ GNU Image Manipulation Program
		#jellyfin-media-player
		kdePackages.kcharselect #...................... Tool to select and copy special characters from all installed fonts
		#kdePackages.kdenlive #......................... Free and open source video editor, based on MLT Framework and KDE Frameworks
		#kicad #....................................... open source electronics design automation suite
		libnotify #.................................... a library that sends desktop notifications to a notification daemon
		#librecad #.................................... 2D CAD package based on Qt
		libreoffice
		#logisim-evolution #........................... Digital logic designer and simulator
		#materialgram #................................. Alternate Telegram client with material theme
		mpv #.......................................... video and music player
		obsidian #..................................... notes
		obs-studio
		#protonvpn-gui
		#qucs-s #...................................... Analog and Digital circuit simulator
		#slack
		#telegram-desktop
		#tg #.......................................... terminal client for telegram
		#(tic-80.override { withPro = true; } ) #...... Fantasy game console
		#thunderbird #................................. email client
		#tor-browser-bundle-bin
		#virtualbox #.................................. virtual machines
		vlc #.......................................... media player
		#wezterm #..................................... terminal emulator
		zathura #...................................... pdf/epub viewer
	];
}
