{ config, pkgs, ... }:
{
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
