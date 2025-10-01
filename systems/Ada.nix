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
{ config, pkgs, ... }:
let
	HOSTNAME = "Ada";
	#HOSTDOMAIN = "";
	HOSTID = "96bfef23"; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "nico";
	TIMEZONE = "America/Los_Angeles";
in {
	imports = [
		#../hardware/pegatron_corp_2ad5.nix
		../modules/Core.nix
		#../modules/Desktops/kde-plasma.nix
		../modules/ssh.nix
		../modules/samba.nix
		../modules/jellyfin.nix
		#../modules/nextcloud.nix
		../modules/freshrss.nix
	];

	# ----- BOOT -----
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
		# Optionally use a different kernel:
		#kernelPackages = pkgs.linuxPackages_latest_hardened; # No longer supported, must specify exact hardened kernel
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
	
	# ----- NETWORKING -----
	networking = {
		hostName = "${HOSTNAME}";
		hostId = "${HOSTID}"; # for zfs. generated with: head -c4 /dev/urandom | od -A none -t x4
		#domain = "${HOSTDOMAIN}";
	};

	# ----- USERS -----
	users.users = {
		"${USER}" = {
			isNormalUser = true;
			extraGroups = [ "networkmanager" "wheel" ];
			openssh.authorizedKeys.keyFiles = [
				/home/${USER}/.ssh/authorized_keys/horcrux.pub
				/home/${USER}/.ssh/authorized_keys/workstation.pub
				/home/${USER}/.ssh/authorized_keys/tome.pub
				/home/${USER}/.ssh/authorized_keys/altar.pub
			];
		};
		#"vaults" = {
			#isNormalUser = false;
		#};
	};
	
	# ----- SYSTEM -----
	security = {
		sudo.enable = false;
		doas = {
			enable = true;
			extraRules = [{
				users = [ "${USER}" ];
				keepEnv = true;
				persist = false;
			}];
		};
	};
	system = {
		copySystemConfiguration = true;
		autoUpgrade = {
			enable = true;
			allowReboot = true;
			dates = "Saturday 01:30 ${TIMEZONE}";
		};
	};
	nix = {
		settings = {
			#experimental-features = [ "nix-command" "flakes" ];
			allowed-users = [ "@wheel" ];
		};
		gc = {
			automatic = true;
			dates = "Saturday 04:00 ${TIMEZONE}";
			options = "--delete-older-than 30d";
		};
		# Auto-garbage collect when less than a certain amount of free space available
		extraOptions = ''
			min-free = ${toString (512 * 1024 * 1024)}
		'';
	};
	services.usbmuxd = { # IOS device connectivity
		enable = false;
		#package = pkgs.usbmuxd2;
	};

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

		#nerd-fonts._0xproto
		#nerd-fonts.adwaita-mono
		#nerd-fonts.blex-mono
		#nerd-fonts.comic-shanns-mono
		#nerd-fonts.im-writing
		#nerd-fonts.intone-mono
		#nerd-fonts.iosevka
		#nerd-fonts.iosevka-term
	];

	# ----- EXTRA SYSTEM PACKAGES -----
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
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
		wget
		yt-dlp

		# ~ Utilities ~
		bat #.......................................... pretty cat for the terminal
		#borgbackup #.................................. Deduplicating archiver with compression and encryption
		cbonsai #...................................... screensaver
		#cope #........................................ A colourful wrapper for terminal programs
		ffmpeg
		fzf
		#glow #........................................ cli markdown renderer
		#ifuse
		#lazygit #..................................... TUI git
		#libimobiledevice #............................. IOS device connection
		libnotify #.................................... notify-send
		libsixel #..................................... SIXEL library for console graphics, and converter programs
		#mtm #......................................... Perhaps the smallest useful terminal multiplexer in the world
		p7zip #........................................ zip utility
		#pistol #...................................... file previewer
		#qemu #........................................ Generic and open source machine emulator and virtualizer
		rclone #....................................... Like rsync but for cloud storage services
		#restic #...................................... A backup program that is fast, efficient, and secure
		rsync
		trash-cli #.................................... trash can for the commandline. Don't accidentally rm something important ;)
		unipicker #.................................... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		#ventoy #...................................... live-usb

                # ~ Productivity ~
		#abduco #...................................... Allows programs to be run independently from its controlling terminal
		#aerc #........................................ Email client for your terminal
		#dvtm #........................................ Dynamic virtual terminal manager
		lf #........................................... file manager
		#neomutt #..................................... Small but very powerful text-based mail client
		#nnn #......................................... minimal file manager
		tmux #......................................... widely-used terminal multiplexer
		#w3m #.......................................... Text-mode web browser
		#xplr #........................................ Hackable, minimal, fast TUI file explore
		#zellij #...................................... user-friendly terminal multiplexer
	];

	# ----- SAMBA -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/samba/Portal  755 root users"
		"d /srv/samba/School  755 root users"
		"d /srv/samba/Library 755 root users"
	];

	services.samba.settings = {
		"Portal" = {
			path = "/srv/samba/Portal";
			browseable = "yes";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
		"School" = {
			path = "/srv/samba/School";
			browseable = "yes";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
		"Library" = {
			path = "/srv/samba/Library";
			browseable = "yes";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
		#"Vaults" = {
			#path = "/srv/samba/Vaults";
			#browseable = "no";
			#public = "no";
			#"read only" = "no";
			#"guest ok" = "no";
			#"valid users" = "vaults";
		#};
	};

	# ----- HEARTBEAT -----
	# Have you tried turning it off and back on again?
	systemd.timers."heartbeat" = {
		wantedBy = [ "timers.target" ];
		timerConfig = {
			Unit = "heartbeat.service";
			#OnCalendar = "15m";
			Persistent = false;
			OnBootSec = "15m";
			OnUnitActiveSec = "15m";
		};
	};
	systemd.services."heartbeat" = {
		script = ''
			#!${pkgs.runtimeShell}
			#if [ ! $(echo -n >/dev/tcp/8.8.8.8/53; echo $?) ]; then
			if [ $(ping -c 3 google.com | grep -q '100% packet loss') || $(ping -c 3 google.com | grep -q 'Name or service not known') ]; then
				nmcli connection down
				sleep 2s
				nmcli connection up e00cb391-acea-4fc5-a2b9-982fd9ece7e9
			fi
		'';
		serviceConfig = {
			Type = "oneshot";
			User = "root";
		};
	};
}
