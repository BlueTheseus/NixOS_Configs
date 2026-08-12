{ config, pkgs, lib, ... }:
let
	USER = "Xenia";
in {
	# ----- SAMBA -----
	# https://nixos.wiki/wiki/Samba
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk/portals/samba         755 root users"
		"d /dsk/portals/samba/Portal  755 root users"
		"d /dsk/portals/samba/School  755 root users"
		"d /dsk/portals/samba/Library 755 root users"
	];
	# /etc/nixos/secrets/samba
	# username=<USERNAME>
	# domain=<DOMAIN> # (optional)
	# password=<PASSWORD>
	fileSystems."/dsk/portals/samba/Portal" = {
		device = "//srv/Portal";
		fsType = "cifs";
		options = let
			# this line prevents hanging on network split
			automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=/etc/nixos/secrets/samba"];
	};
	fileSystems."/dsk/portals/samba/School" = {
		device = "//srv/School";
		fsType = "cifs";
		options = let
			# this line prevents hanging on network split
			automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=/etc/nixos/secrets/samba"];
	};
	fileSystems."/dsk/portals/samba/Library" = {
		device = "//srv/Library";
		fsType = "cifs";
		options = let
			# this line prevents hanging on network split
			automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=/etc/nixos/secrets/samba"];
	};

	# ----- SYNCTHING -----
	systemd.services."syncthingd" = {
		script = ''#!${pkgs.runtimeShell} syncthing'';
		serviceConfig = {
			Type = "oneshot";
			User = "${USER}";
		};
	};


	# ----- VIRTUALBOX -----
	virtualisation.virtualbox = {
		host = {
			enable = true;
			enableExtensionPack = false; # Enabling this results in compiling from source, which is slow and resource-intensive
		};
	};
	users.extraGroups.vboxusers.members = [ "${USER}" ];
	boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # temp fix: https://discourse.nixos.org/t/issue-with-virtualbox-in-24-11/57607

	# ----- DOCKER -----
	virtualisation.docker = {
		enable = true;
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};
}
