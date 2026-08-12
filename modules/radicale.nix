{ config, pkgs, ... }:
{
	# ----- SYSTEM -----
	#systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
	#];

	services.radicale = {
		enable = true;
		settings = {
			server.hosts = [ "0.0.0.0:5232" ];
			auth.type = "none";
		};
	};

}
