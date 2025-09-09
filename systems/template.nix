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
	HOSTNAME = "";
	HOSTID = ""; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "";
	TIMEZONE = "America/Los_Angeles";
in {
	imports = [
		#../hardware/
		../modules/Core.nix
		#../modules/Extras.nix
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

	# ----- EXTRA SYSTEM PACKAGES -----
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		# ~ System ~
		#auto-cpufreq #...... auto cpu speed & power optimizer
		#busybox #.......... Tiny versions of common UNIX utilities in a single small executable
		#cgdisk
		#clang #............ A C language family frontend for LLVM (wrapper script)
		cpulimit #.......... archived, use limitcpu -- however only this works to successfully limit children processes
		#libclang #......... A C langauge family frontend for LLVM -- provides clang and clang++
		#libgcc #........... GNU Compiler Collection
		#libuuid #.......... A set of system utilities for Linux (util-linux-minimal)
		#limitcpu
		#toybox #........... Lightweight implementation of some Unix command line utilities
		#usbutils #......... Tools for working with USB devices, such as lsusb
	];
}
