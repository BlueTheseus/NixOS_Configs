{ config, ... }:
let
	USER = "";
in {

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/samba/Private 755 root users"
		"d /srv/samba/Public  755 root users"
	];

	# ----- SAMBA -----
	services.samba.settings = {
		"Private" = {
			path = "/srv/samba/Private";
			browseable = "no";
			public = "no";
			"read only" = "no";
			"guest ok" = "no";
			"valid users" = "${USER}";
		};
		"Public" = {
			path = "/srv/samba/Public";
			browseable = "yes";
			public = "yes";
			"read only" = "yes";
			"guest ok" = "yes";
		};
	};
}
