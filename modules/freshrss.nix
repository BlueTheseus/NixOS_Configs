{ config, pkgs, ... }:

let
	FRESHRSS_URL = "http://freshrss.${config.networking.hostName}";
in {
	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		freshrss
	];

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/freshrss 755 root users"
		"d /srv/freshrss/data 755 root users"
	];

	# ----- SETTINGS -----
	services.freshrss = {
		enable = true;
		#authType = "none";  # Authentication type for FreshRSS. Choices: "form" (default), "http_auth", "none"
		baseUrl = "${FRESHRSS_URL}";  # Default URL for FreshRSS
		dataDir = "/srv/freshrss/data";  # Default data folder for FreshRSS. Default: "/var/lib/freshrss"
		defaultUser = "skoink";  # Default username for FreshRSS. Default: "admin"
		language = "en";  # Default language for FreshRSS. Default: "en"
		#package = pkgs.freshrss;  # Which FreshRSS package to use. Default: pkgs.freshrss
		passwordFile = "/srv/freshrss/secret";  # Password for the defaultUser for FreshRSS. Default: null
		#pool = "freshrss"  # Name of the phpfpm pool to use and setup. Default: "freshrss"
		#user = "freshrss"  # User under which FreshRSS runs. Default: "freshrss"
		#virtualHost = "freshrss"  # Name of the nginx virtualhost to use and setup. Default: "freshrss"
	};
}
