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
	HOSTNAME = "Shelby";
	HOSTID = "a66e5646"; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "Eden";
	TIMEZONE = "America/Los_Angeles";
in {
	imports = [
		../modules/Core.nix
		../modules/Desktops/cosmic.nix
		../modules/ssh.nix
		../modules/samba.nix
		../modules/jellyfin.nix
		#../modules/nextcloud.nix
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
	#specialisation = {
		#CopyToRAM.configuration = {
			#system.nixos.tags = [ "Copy_To_RAM" ];
			boot.kernelParams = [ "copytoram" ];
		#};
	#};

	# ----- LOCALISATION -----
	time.timeZone = "${TIMEZONE}";
	
	# ----- NETWORKING -----
	networking = {
		hostName = "${HOSTNAME}";
		hostId = "${HOSTID}"; # for zfs. generated with: head -c4 /dev/urandom | od -A none -t x4
	};

	# ----- USERS -----
	users.users = {
		"${USER}" = {
			isNormalUser = true;
			extraGroups = [ "networkmanager" "wheel" ];
			openssh.authorizedKeys.keyFiles = [
				/home/${USER}/.ssh/authorized_keys/horcrux.pub
				/home/${USER}/.ssh/authorized_keys/workstation.pub
			#	/home/${USER}/.ssh/authorized_keys/tome.pub
			#	/home/${USER}/.ssh/authorized_keys/altar.pub
			];
		};
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
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/qemu 775 root users"
	];

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
		#google-fonts #...... Font files available from Google Fonts
		#noto-fonts #........ Beautiful and free fonts for many languages
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
		cpulimit #..................................... archived, use limitcpu -- however only this works to successfully limit children processes
		usbutils #..................................... Tools for working with USB devices, such as lsusb

		# ~ Info ~
		#exiftool #.................................... file metadata
		fastfetch
		#mediainfo

		# ~ Networking ~
		#bluez #....................................... Official linux bluetooth protocol stack
		#cifs-utils #.................................. Samba
		#curl
		#dnsutils
		#mosh #........................................ Mobile shell (ssh replacement)
		#wget
		yt-dlp

		# ~ Utilities ~
		#bat #......................................... pretty cat for the terminal
		#bc #.......................................... Basic Calculator
		#borgbackup #.................................. Deduplicating archiver with compression and encryption
		#cbonsai #..................................... screensaver
		ffmpeg
		#glow #........................................ cli markdown renderer
		#ifuse
		#libimobiledevice #............................ IOS device connection
		libsixel #..................................... SIXEL library for console graphics, and converter programs
		#lz4 #......................................... Extremely fast compression algorithm
		nemu #......................................... Ncurses UI for QEMU
		#outils #...................................... Port of OpenBSD-exclusive tools -- included for md5
		qemu #......................................... Generic and open source machine emulator and virtualizer
		rclone #....................................... Like rsync but for cloud storage services
		#restic #...................................... A backup program that is fast, efficient, and secure
		rsync
		#unipicker #................................... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		#zstd #........................................ Zstandard real-time compression algorithm

		# ~ Productivity ~
		lf #........................................... file manager
		nnn #.......................................... minimal file manager
		tmux #......................................... widely-used terminal multiplexer
		#w3m #......................................... Text-mode web browser

		# ~ Desktop ~
		#bluez #....................................... official linux bluetooth protocol stack
		brave #........................................ browser
		discord
		#firefox #..................................... browser
		foot #......................................... wayland terminal
		kdePackages.kcharselect #...................... Tool to select and copy special characters from all installed fonts
		libnotify #.................................... a library that sends desktop notifications to a notification daemon
		libreoffice
		mpv #.......................................... video and music player
		obsidian #..................................... notes
		obs-studio
		#virtualbox #.................................. virtual machines
		vlc #.......................................... media player
		zathura #...................................... pdf/epub viewer
	];

	# ----- SAMBA -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/samba/Media  755 root users"
		"d /srv/samba/School 755 root users"
	];

	services.samba.settings = {
		"Media" = {
			path = "/srv/samba/Media";
			browseable = "yes";
			public = "no";
			"read only" = "yes";
			"guest ok" = "yes";
		};
		"School" = {
			path = "/srv/samba/School";
			browseable = "yes";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
	};
}
