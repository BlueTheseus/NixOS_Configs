{config, pkgs, lib, ... }:
{
	# Make sure certain directories exist
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/nextcloud         0755 nextcloud nextcloud"
		"d /srv/nextcloud/data    0755 nextcloud nextcloud"
		#"d /srv/nextcloud/backups 0755 nextcloud nextcloud"
	];

	# ----- NEXTCLOUD -----
	services.nextcloud = {
		enable = true;
		package = pkgs.nextcloud32;
		home = "/srv/nextcloud/data"; #.... folder for nextcloud's files
		hostName = "nextcloud";
		database.createLocally = true;
		configureRedis = true;
		#https = false;
		config = {
			adminpassFile = "/srv/nextcloud/secret";
			adminuser = "Nex";
			dbtype = "pgsql";
			#dbname = "nextcloud";
			#dbuser = "nextcloud";
		};
		extraAppsEnable = true;
		extraApps = {
			inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts notes tasks news cookbook; #twofactor webauthn onlyoffice immich_integration
		};
		#autoUpdateApps.enable = true;
		maxUploadSize = "1000G";
		settings = {
			overwriteprotocol = "http";
			#trusted_domains = [ "" ];
			#trusted_proxies = [ "" ];
		};
	};


	# The following line clears Nextcloud's "wantedby" setting for its
	# systemd service. This means Nextcloud won't start automatically
	# at boot and must be manually started with the command
	# 'systemctl start nextcloud-setup.service' . This is handy for when you
	# don't want to start the service until you manually mount or
	# decrypt its data directory.
	systemd.services.nextcloud-setup.wantedBy = lib.mkForce [];

	# ----- POSTGRES DATABASE -----
	# https://mich-murphy.com/configure-nextcloud-nixos/
	#services = {
	#	postgresql = {
	#		enable = true;
	#		ensureDatabases = [ "nextcloud" ];
	#		ensureUsers = [{
	#			name = "nextcloud";
	#			#ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
	#		}];
	#	};
	#	# optional backup for postgresql db
	#	postgresqlBackup = {
	#		enable = true;
	#		location = "/srv/nextcloud/backups";
	#		databases = [ "nextcloud" ];
	#		# time to start backup in systemd.time format
	#		startAt = "Sun *-*-* 03:00:00";
	#	};
	#};

	# ensure postgresql db is started with nextcloud
	#systemd = {
	#	services."nextcloud-setup" = {
	#		requires = [ "postgresql.service" ];
	#		after = [ "postgresql.service" ];
	#	};
	#};

	# ----- FIREWALL -----
	# how to open to world???
	#networking.firewall = {
		#allowedTCPPorts = [ 80 8080 ];
		#allowedUDPPorts = [ 80 8080 ];
	#};


	# ----- HTTPS -----
	services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
		forceSSl = false; #...... true for https
		#addSSL = false;
		enableACME = false; #.... true for https
		listen = [
			{ addr = "0.0.0.0"; port = 42020; }
		];
	};
	#security.acme = {
		#acceptTerms = true;
		#certs = {
			#${config.services.nextcloud.hostName}.email = "interwebs.quantum622@passinbox.com";
		#};
	#};
}
