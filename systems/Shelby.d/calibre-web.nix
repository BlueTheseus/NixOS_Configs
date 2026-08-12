{ config, pkgs, ... }:
let
	LISTEN_IP = "100.65.2.3";
in {
	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /srv/calibre-web         0750 calibre-web users"
		"d /srv/calibre-web/data    0750 calibre-web users"
		"d /srv/calibre-web/library 0750 calibre-web users"
	];

	# ----- SETTINGS -----
	services.calibre-web = {
		enable = true;
		dataDir = "/srv/calibre-web/data";
		user = "calibre-web";
		listen = {
			ip = LISTEN_IP;
			port = 42083;
		};
		options = {
			calibreLibrary = "/srv/calibre-web/library";
			enableBookUploading = true;
			enableKepubify = true;
		};
	};
}
