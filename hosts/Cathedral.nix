{ config, pkgs, ... }:

let
	HOSTNAME = "cathedral";
in {
	# ----- MODULES -----
	imports = [
		./modules/hosting/ssh.nix
		./modules/hosting/samba.nix
		./modules/hosting/jellyfin.nix
	];

	# ----- BOOT -----
	boot = {
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
	};
	supportedFilesystems = [ "zfs" ];
	zfs.forceImportRoot = false;

	# ----- NETWORKING -----
	networking = {
		hostName = ${HOSTNAME};
		hostId = "96bfef23";
		networkmanager.enable = true;
		firewall = {
			enable = true;
			trustedInterfaces = [ "tailscale0" ];
		};
		#nftables.enable = true;
	};
	services.tailscale.enable = true;

	# ----- LOCALIZATION -----
	time.timeZone = "America/Los_Angeles";
	i18n.defaultLocale = "en_US.UTF-8";

	# ----- CONSOLE -----
	console = {
		packages = with pkgs; [];
		font = "Lat2-Terminus16";
		useXkbConfig = true;
	};
	services.xserver.xkb = {
		layout = "us";
		options = "caps:escape";
	};

	# ----- USERS -----
	users.users."nico" = {
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # super user permissions
		#packages = with pkgs; [
			#bat
		#];
		openssh.authorizedKeys.keyFiles = [
			/home/nico/.ssh/authorized_keys/horcrux.pub
			/home/nico/.ssh/authorized_keys/workstation.pub
			#/home/nico/.ssh/authorized_keys/altar.pub
			/home/nico/.ssh/authorized_keys/tome.pub
			#/home/nico/.ssh/authorized_keys/grimoire.pub
			/home/nico/.ssh/authorized_keys/pass.pub
		];
	};

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /dsk           0755 root users" #.... mount point for all storage disks
		"d /dsk/chest     0755 root users" #.... mirrored drives
		"d /dsk/ephemeral 0755 root users" #.... for non-valuables
		"d /srv           0755 root users"
	];
	nix.settings.allowed-users = [ "@wheel" ];
	security = {
		sudo.enable = false;
		doas = {
			enable = true;
			extraRules = [{
				users = [ "nico" ];
				keepEnv = true;
				persist = true;
			}];
		};
	};
	programs = {
		mtr.enable = true;
		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};
	};
	system.copySystemConfiguration = true;
}
