{ config, pkgs, ... }:
let
	HOSTNAME = "";
	HOSTID = ""; # for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "";
	TIMEZONE = "America/Los_Angeles";
in {
	# ----- BOOT -----
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
	};
	supportedFilesystems = [ "zfs" "ntfs" ];
	zfs.forceImportRoot = false;
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
	system.copySystemConfiguration = true;
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk         755 root users" #.... Like /mnt but for disks which are always mounted
		"d /dsk/cellar  775 root users" #.... extra storage space
		"d /dsk/chest   755 root users" #.... safer storage via raid
		"d /dsk/archive 755 root users" #.... local copy of data (such as from server)
		"d /dsk/portal  755 root users" #.... for samba shares and the like -- portals to other places
	];
	boot = {
		supportedFilesystems = [ "zfs" "ntfs" ];
		zfs.forceImportRoot = false;
	};
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
		# ~ Minimum ~
		btrfs-progs #....... BTRFS utils
		#busybox #.......... Tiny versions of common UNIX utilities in a single small executable
		#clang #............ A C language family frontend for LLVM (wrapper script)
		gcc
		git
		gnumake
		gptfdisk #.......... TUI disk management
		#libclang #......... A C langauge family frontend for LLVM -- provides clang and clang++
		#libgcc #........... GNU Compiler Collection
		#libuuid #.......... A set of system utilities for Linux (util-linux-minimal)
		micro
		nano
		neovim #............ Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		pciutils #.......... A collection of programs for inspecting and manipulating configuration of PCI devices
		#toybox #........... Lightweight implementation of some Unix command line utilities
		usbutils #.......... Tools for working with USB devices, such as lsusb
		util-linux #........ A set of system utilities for Linux
		exfat #............. Free exFAT file system implementation
		zfs

		# ~ Encryption ~
		cryptsetup
		gnupg
		#gpg-tui #.......... Terminal user interface for GnuPG
		tomb
		pass #.............. Stores, retrieves, generates, and synchronizes passwords securely
		pinentry-curses #... needed by tomb

		# ~ Fonts ~
		#nerdfonts
		#inter #............. A typeface specially designed for user interfaces

		# ~ Info ~
		#bunnyfetch
		exiftool #.......... file metadata
		fastfetch
		mediainfo
		#neofetch
		#starfetch
		#uwufetch

		# ~ Networking ~
		cifs-utils #........ samba
		curl
		networkmanager
		#spotdl
		tailscale
		wget
		wpa_supplicant
		yt-dlp

		# ~ System Management ~
		auto-cpufreq #...... auto cpu speed & power optimizer
		btop #.............. system monitoring
		#limitcpu
		cpulimit #.......... archived, use limitcpu -- however only this works to successfully limit children processes
		powertop #.......... power monitoring and management
		tlp #............... battery and power daemon

		# ~ Terminal Utilities ~
		#abduco #........... Allows programs to be run independently from its controlling terminal
		bat #............... pretty cat for the terminal
		#borgbackup #....... Deduplicating archiver with compression and encryption
		cbonsai #........... screensaver
		#cope #............. A colourful wrapper for terminal programs
		#dvtm #............. Dynamic virtual terminal manager
		ffmpeg
		fzf
		glow #.............. cli markdown renderer
		#lazygit #........... tui git
		lf #................ file manager
		#libnotify #......... notify-send
		#most #............. A terminal pager similar to 'more' and 'less'
		#mtm #.............. Perhaps the smallest useful terminal multiplexer in the world
		p7zip
		#pistol #............ file previewer
		rclone #............ Like rsync but for cloud storage services
		#restic #........... A backup program that is fast, efficient, and secure
		rsync
		#texliveSmall
		tmux #.............. terminal multiplexer
		trash-cli #......... don't accidentally rm something important ;)
		#uxn #............... Assembler and emulator for the Uxn stack machine
		ventoy #............ live-usb

		# ~ Documents ~
		# TO DO: remove this section and make into nix-shell environments instead
		#graphviz
		#pandoc
		#python312
		#python312Packages.numpy
		#python312Packages.matplotlib
		#python312Packages.scipy
		#texliveConTeXt
		#texliveFull
		#typst
		unipicker #........ CLI utility for searching unicode characters by description and optionally copying them to clipboard
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

		#(nerdfonts.override { fonts = [    #.... Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts
			#"iA-Writer"
			#"IBMPlexMono"
			#"IntelOneMono"
			#"Iosevka"
			#"IosevkaTerm"
		#]; }) 
	];
}
