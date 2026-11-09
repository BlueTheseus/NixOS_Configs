{ config, ... }:
{
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
}
