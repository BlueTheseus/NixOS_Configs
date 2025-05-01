# Available at port 5000 by default
# Requires nginx or apache

{config, ... }:
{
	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv 0755 root users" #............ mount point for other storage disks
		"d /srv/kavita 0775 root users" #........ for storing local git repositories. Symlink to where they are expected to be
	];
	#networking.firewall.allowedTCPPorts = [ 42005 ];

	# ----- SETTINGS -----
	services.kavita = {
		enable = true;
		dataDir = "/srv/kavita/data";
		#ipAddresses = [];
		#package = ;
		port = 42005;
		tokenKeyFile = "/srv/kavita/secret"; # can be generated with `head -c 32 /dev/urandom | base64`
		#settings = {};
	};
}
