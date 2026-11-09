# https://nixos.wiki/wiki/Samba
{ config, ... }:
let
	SAMBAPASS = "/srv/samba/secret";
in {
	# ----- SAMBA -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /dsk/portals/samba            755 root users"
		"d /dsk/portals/samba/SambaShare 755 root users"
	];
	# /srv/samba/secret
	# username=<USERNAME>
	# domain=<DOMAIN> # (optional)
	# password=<PASSWORD>
	fileSystems."/dsk/portals/samba/SambaShare" = {
		device = "//server/SambaShare";
		fsType = "cifs";
		options = let
			# this line prevents hanging on network split
			automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=${SAMBAPASS}"];
	};
}
