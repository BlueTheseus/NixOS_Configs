{ config, pkgs, ... }:
let
	USER = "Eden";
in {

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/qemu          755 root users"
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

	# ----- DOCKER -----
	virtualisation.docker = {
		#enable = true;
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};
	# Enable Docker rootless mode to bind to privileged ports
	security.wrappers = {
		docker-rootlesskit = {
			owner = "root";
			group = "root";
			capabilities = "cap_net_bind_service+ep";
			source = "${pkgs.rootlesskit}/bin/rootlesskit";
		};
	};
	# Enable IPv4 packet forwarding
	boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

}
