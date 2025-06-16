# Filesystem Recommendations:
# 	- BTRFS
# 	- Separate root and home partitions
# Swap:
# 	- Recommended size: (amount of RAM) + sqrt(amount of RAM)
{ config, pkgs, ... }:
let
	HOSTNAME = "";
	HOSTID = ""; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "";
	TIMEZONE = "America/Los_Angeles";
	AUTO_UPGRADE = false;
	AUTO_GC = false
in {
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

	# ----- LOCALISATION -----
	time.timeZone = "${TIMEZONE}";
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus32";
		useXkbConfig = true;
	};
	services.xserver.xkb = {
		layout = "us";
		options = "caps:escape";
	};
	
	# ----- NETWORKING -----
	networking = {
		hostName = "${HOSTNAME}";
		networkmanager.enable = true;
		#wireless.enable = false; # uses wpa_supplicant
		hostId = "${HOSTID}"; # for zfs. generated with: head -c4 /dev/urandom | od -A none -t x4
		firewall = {
			enable = true;
			trustedInterfaces = [ "tailscale0" ];
		};
	};

	# ----- USERS -----
	users.users."${USER}" = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" ];
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
			enable = ${AUTO_UPGRADE};
			allowReboot = true;
			dates = "daily 01:30 ${TIMEZONE}";
		};
	};
	nix = {
		gc = {
			automatic = ${AUTO_GC};
			dates = "Saturday 04:00 ${TIMEZONE}";
			options = "--delete-older-than 7d";
		};
		# Auto-garbage collect when less than a certain amount of free space available
		extraOptions = ''
			min-free = ${toString (512 * 1024 * 1024)}
		'';
	};
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk         755 root users" #.... Like /mnt but for disks which are always mounted
		"d /dsk/cellars  775 root users" #.... extra storage space
		"d /dsk/chests   755 root users" #.... safer storage via raid
		"d /dsk/archives 755 root users" #.... local copy of data (such as from server)
		"d /dsk/portals  755 root users" #.... for samba shares and the like -- portals to other places
	];
	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];
		allowed-users = [ "@wheel" ];
	};

	# ----- SUID WRAPPERS -----
	programs = {
		mtr.enable = true;
		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};
	};

	# ----- SERVICES -----
	services = {
		fwupd.enable = true;
		tailscale.enable = true;
	};

	# ----- PACKAGES -----
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		# ~ Editors ~
 		# Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		micro
		nano
		neovim

		# ~ System ~
		auto-cpufreq #...... auto cpu speed & power optimizer
		btrfs-progs #....... BTRFS utilities
		#busybox #.......... Tiny versions of common UNIX utilities in a single small executable
		#cgdisk
		#clang #............ A C language family frontend for LLVM (wrapper script)
		cpulimit #.......... archived, use limitcpu -- however only this works to successfully limit children processes
		gcc
		git
		gnumake
		gptfdisk #.......... TUI disk management
		#libclang #......... A C langauge family frontend for LLVM -- provides clang and clang++
		#libgcc #........... GNU Compiler Collection
		#libuuid #.......... A set of system utilities for Linux (util-linux-minimal)
		#limitcpu
		pciutils #.......... A collection of programs for inspecting and manipulating configuration of PCI devices
		powertop #.......... power monitoring and management
		tlp #............... battery and power daemon
		#toybox #........... Lightweight implementation of some Unix command line utilities
		#usbutils #.......... Tools for working with USB devices, such as lsusb
		util-linux #........ A set of system utilities for Linux
		exfat #............. Free exFAT file system implementation
		zfs #............... ZFS utilities

		# ~ Encryption ~
		cryptsetup
		gnupg
		#gpg-tui #.......... Terminal user interface for GnuPG
		tomb
		pass #.............. Stores, retrieves, generates, and synchronizes passwords securely
		pinentry-curses #... needed by tomb

		# ~ Info ~
		#bunnyfetch
		exiftool #.......... file metadata
		fastfetch
		mediainfo
		#starfetch
		#uwufetch

		# ~ Networking ~
		#cifs-utils #........ samba
		#curl
		#dnsutils
		networkmanager
		tailscale
		#wget
		wpa_supplicant
		#yt-dlp

		# ~ Terminal Utilities ~
		#abduco #........... Allows programs to be run independently from its controlling terminal
		#bat #............... pretty cat for the terminal
		#borgbackup #....... Deduplicating archiver with compression and encryption
		btop #.............. system monitoring
		#cope #............. A colourful wrapper for terminal programs
		#dvtm #............. Dynamic virtual terminal manager
		ffmpeg
		fzf
		#mtm #.............. Perhaps the smallest useful terminal multiplexer in the world
		nnn #............... minimal file manager
		p7zip
		#pistol #........... file previewer
		#rclone #............ Like rsync but for cloud storage services
		#restic #........... A backup program that is fast, efficient, and secure
		rsync
		tmux #.............. terminal multiplexer
		trash-cli #......... don't accidentally rm something important ;)
		unipicker #......... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		zellij #............ user-friendly terminal multiplexer
	];

	# ~ Fonts ~
	fonts.packages = with pkgs; [
		cozette #........... A bitmap programming font optimized for coziness
		dina-font #......... A monospace bitmap font aimed at programmers
		#google-fonts #...... Font files available from Google Fonts
		#noto-fonts #........ Beautiful and free fonts for many languages
		scientifica #....... Tall and condensed bitmap font for geeks
		siji #.............. An iconic bitmap font based on Stlarch with additional glyphs
		spleen #............ Monospaced bitmap fonts
		tamsyn #............ A monospace bitmap font aimed at programmers
		tamzen #............ Bitmapped programming font based on Tamsyn
		tewi-font #......... A nice bitmap font, readable even at small sizes
		ucs-fonts #......... Unicode bitmap fonts
		unifont #........... GNU's Unicode font for Base Multilingual Plane
		unscii #............ Bitmapped character-art-friendly Unicode fonts
	];
}
