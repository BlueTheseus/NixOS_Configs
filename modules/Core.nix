# Filesystem Recommendations:
# 	- BTRFS
# 	- Separate root and home partitions
# Swap:
# 	- Recommended size: (amount of RAM) + sqrt(amount of RAM)
{ config, pkgs, ... }:
{
	# ----- LOCALISATION -----
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus32";
		useXkbConfig = true;
	};
	services.xserver.xkb = {
		layout = "us";
		options = "caps:escape"; # Turn CapsLock into Escape
	};
	
	# ----- NETWORKING -----
	networking = {
		networkmanager.enable = true; # Choose either networkmanager OR wpa_supplicant
		#wireless.enable = false; # Uses wpa_supplicant
		firewall = {
			enable = true;
			trustedInterfaces = [ "tailscale0" ];
		};
	};
	
	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv          755 root users" #.... services
		"d /dsk          755 root users" #.... Like /mnt but for disks which are always mounted
		"d /dsk/cellars  775 root users" #.... extra storage space
		"d /dsk/chests   755 root users" #.... safer storage via raid
		"d /dsk/archives 755 root users" #.... local copy of data (such as from server)
		"d /dsk/portals  755 root users" #.... for samba shares and the like -- portals to other places
	];

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
		fwupd.enable = true; # Firmware Updater
		tailscale.enable = true;
		#tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; }; # Temporary fix to allow upgrading from a broken kernel (pre-6.12.46) to a fixed kernel (6.12.46 and above). Must also comment out tailscale in system packages.
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
		gcc #............... GNU C Compiler
		gdb #............... GNU Debugger
		git
		gnumake
		gptfdisk #.......... TUI disk management
		pciutils #.......... A collection of programs for inspecting and manipulating configuration of PCI devices
		powertop #.......... power monitoring and management
		tlp #............... battery and power daemon
		util-linux #........ A set of system utilities for Linux
		exfat #............. Free exFAT file system implementation
		zfs #............... ZFS utilities

		# ~ Encryption ~
		cryptsetup
		gnupg
		keepassxc #......... Provides keepassxc-cli
		tomb
		pass #.............. Stores, retrieves, generates, and synchronizes passwords securely
		pinentry-curses #... needed by tomb

		# ~ Networking ~
		networkmanager
		tailscale
		wpa_supplicant

		# ~ Terminal Utilities ~
		btop #.............. system monitoring
	];
}
