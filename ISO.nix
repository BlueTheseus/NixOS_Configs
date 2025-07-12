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
# - specialisation
# 	- create kde/gnome desktop options -- include individual desktop files
# - add minimal.nix to imports to prevent copy/pasting

{ pkgs, modulesPath, lib, ... }:
let
	ARCHITECTURE = "x86_64-linux";
in {
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
		./modules/Core.nix
		./modules/Extras.nix
	];

	nixpkgs.hostPlatform = "${ARCHITECTURE}";

	# ----- NIX SETTINGS -----
	# Faster compression in exchange for larger file size:
	#isoImage.squashfsCompression = "gzip -Xcompression-level 1";

	# ----- SYSTEM -----
	networking = lib.mkDefault {
		hostName = "Nomad";
		hostId = "bc921301"; # for zfs -- generated with: head -c4 /dev/urandom | od -A none -t x4
		wireless.enable = false; # Enables networking support via wpa_supplicant
		networkmanager.enable = true; # Choose one between network manager and wpa_supplicant
		firewall = {
			enable = true;
			trustedInterfaces = [ "tailscale0" ];
		};
		interfaces.eth0.ipv4.addresses = [{
			address = "10.0.0.5";
			prefixLength = 24;
		}];
		defaultGateway = "10.0.0.5";
		#nameservers = [ "8.8.8.8" ];
	};
	programs = {
		mtr.enable = true;
		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};
	};
	systemd.tmpfiles.rules = lib.mkDefault [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk 755 root users"
		"d /dsk/persistent 755 root users"
		#"d /dsk/tmp 755 root users"
	];
	users = lib.mkDefault {
		#motdFile = "";
		users."nomad" = {
			isNormalUser = true;
			extraGroups = [ "networkmanager" "wheel" ];
			initialPassword = "ontherun!";
			#openssh.authorizedKeys.keyFiles = [
				#/home/nomad/.ssh/authorized_keys/\*
			#];
		};
	};

	# ----- SERVICES -----
	services = {
		fwupd.enable = true; # Firmware updater
		tailscale.enable = true;
		openssh = {
			enable = true;
			settings = {
				PermitRootLogin = lib.mkForce "no";
				PasswordAuthentication = true;
				KbdInteractiveAuthentication = false;
				X11Forwarding = false;
			};
			allowSFTP = true;
			ports = [ 42000 ];
			startWhenNeeded = false;
		};
	};

	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		# ~ System ~
		auto-cpufreq #............. auto cpu speed & power optimizer
		btop #..................... system monitor
		btrfs-progs #.............. BTRFS utilities
		cpulimit #................. archived, use limitcpu -- however only this works properly with children processes
		gcc
		git
		gnumake
		gptfdisk #................. TUI disk management
		micro
		nano
		neovim
		pciutils #.................. A collection of programs for inspecting and manipulating configuration of PCI devices
		powertop
		tlp #....................... battery and power daemon
		usbutils #.................. Tools for working with USB devices, such as lsusb
		util-linux #................ A set of system utilities for linux
		exfat #..................... Free exFAT file system implementation
		zfs
		# ~ Encryption ~
		cryptsetup
		gnupg
		tomb
		pass
		pinentry-curses #........... for tomb
		# ~ General Tools ~
		bat #....................... pretty cat for the terminal
		cbonsai #................... screensaver
		fastfetch
		ffmpeg
		fzf
		glow #...................... cli markdown renderer
		lf #........................ terminal file manager
		p7zip
		rclone #.................... like rsync but for cloud storage services
		rsync
		tmux
		trash-cli
		unipicker #................. CLI utility for searching unicode characters by description and optionally copying them to clipboard
		ventoy
		#disko
		#parted
		# ~ Networking ~
		networkmanager
		openssh
		tailscale
		wget
		wpa_supplicant
	];
	fonts.packages = with pkgs; [
		cozette #................... A bitmap programming font optimized for coziness
		dina-font #................. A monospace bitmap font aimed at programmers
	];

	# ----- OPTIONS -----
	specialisation = {
		#CopyToRAM.configuration = {
			#system.nixos.tags = [ "Copy_To_RAM" ];
			#boot.kernelParams = [ "copytoram" ];
		#};
		KDEdesktop = {
			system.nixos.tags = [ "KDE Desktop" ];
			imports = [ ./modules/KDE_Desktop.nix ];
		};
	};
}
