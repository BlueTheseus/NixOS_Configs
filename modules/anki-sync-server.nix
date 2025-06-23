{ config, ... }:
let
	USER = "";
in {
	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv                        755 root users"
		"d /srv/anki-sync-server       755 root users"
		"d /srv/anki-sync-server/users 755 root users"
		"d /srv/anki-sync-server/data  755 root users"
	];

	# ----- ANKI SERVER -----
	services.anki-sync-server = {
		enable = true;
		baseDirectory = "";
		port = 42050; # default: 27701
		users = {
			"${USER}" = {
				username = "${USER}";
				passwordFile = "/srv/anki-sync-server/users/${USER}";
			};
		};
	};
}
