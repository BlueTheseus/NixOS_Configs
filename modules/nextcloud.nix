{config, pkgs, ... }:
#let 
	#NEXTCLOUD_URL="https://cloud.${config.networking.hostName}";
# in
{
	# Make sure certain directories exist
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/nextcloud 0755 root users"
		"d /srv/nextcloud/data 0755 root users"
	];

	# ----- NEXTCLOUD -----
	services.nextcloud = {
		enable = true;
		#package = pkgs.nextcloud29;
		home = "/srv/nextcloud/data"; #.... folder for nextcloud's files
		#hostName = "${NEXTCLOUD_URL}";
		#hostName = "https://cloud.lost-faye-wilds.duckdns.org";
		hostName = "srv";
		configureRedis = true;
		https = false;
		config = {
			adminpassFile = "/srv/nextcloud/secret";
			adminuser = "Nex";
		};
		extraAppsEnable = true;
		extraApps = {
			inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts notes tasks; #twofactor webauthn onlyoffice news
		};
		maxUploadSize = "1000G";
		settings = {
			overwriteprotocol = "http";
			#trusted_domains = [ "" ];
		};
	};


	# ----- FIREWALL -----
	# how to open to world???
	#networking.firewall = {
		#allowedTCPPorts = [ 80 8080 ];
		#allowedUDPPorts = [ 80 8080 ];
	#};


	# ----- HTTPS -----
	#services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
		#forceSSl = true; #...... true for https
		#enableACME = true; #.... true for https
	#};
	#security.acme = {
		#acceptTerms = true;
		#certs = {
			#${config.services.nextcloud.hostName}.email = "interwebs.quantum622@passinbox.com";
		#};
	#};
}
