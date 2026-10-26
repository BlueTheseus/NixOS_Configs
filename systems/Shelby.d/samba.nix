{ config, pkgs, ... }:
let
	USER = "Eden";
in {

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/samba/Media   755 root users"
		"d /srv/samba/School  755 root users"
		"d /srv/samba/Library 755 root users"
	];

	# ----- SAMBA -----
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
		"Library" = {
			path = "/srv/samba/Library";
			browseable = "yes";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
	};
}
