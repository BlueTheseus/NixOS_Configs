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
	HOSTID = ""; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "nico";
	TIMEZONE = "America/Los_Angeles";
in {
	imports = [
		#../hardware/pegatron_corp_2ad5.nix
		../modules/Core.nix
		#../modules/Extras.nix
		#../modules/Desktops/kde-plasma.nix
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
		"vaults" = {
			isNormalUser = false;
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

	# ----- SAMBA -----
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
		"Vaults" = {
			path = "/srv/samba/Vaults";
			browseable = "no";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "vaults";
		};
	};
}
