# https://nixos.wiki/wiki/Git
#
# Create a repo myproject accessible by user git on the server:
# 	sudo -u git bash -c 'cd /srv/git-server; mkdir myproject.git; cd myproject.git; git init --bare'
#
# For a local git repo
# mkdir myproject && cd myproject && git init
#
# Git remote available at:
# 	git@hostname:myproject.git
#
# Via:
# 	git remote add origin git@hostname:myproject.git

{config, pkgs, ... }:
let
	AUTHORIZED_SSH_KEYFILES = [ ... ];
in {
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv 0755 root users"
		"d /srv/git-server 0775 root users"
	];

	users.users.git = {
		isSystemUser = true;
		group = "git";
		home  = "/srv/git-server";
		createHome = true;
		shell = "${pkgs.git}/bin/git-shell";
		openssh.authorizedKeys.keyFiles = [ ${AUTHORIZED_SSH_KEYFILES} ];
	};

	users.groups.git = {};

	services.openssh = {
		enable = true;
		extraConfig = ''
		Match user git
			AllowTcpForwarding no
			AllowAgentForwarding no
			PasswordAuthentication no
			PermitTTY no
			X11Forwarding no
		'';
	};
}
