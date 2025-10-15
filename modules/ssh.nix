{ config, pkgs, ... }:
{
	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		openssh
	];

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /srv/ssh 0750 root users"
	];

	# ----- SETTINGS -----
	users.motdFile = "/srv/ssh/motd"; # Displayed to users once logged in
	services.openssh = {
		enable = true;
		settings = {
			PermitRootLogin = "no";
			PasswordAuthentication = false; # Disable once you have exchanged keys
			KbdInteractiveAuthentication = false; # Disable once you have exchanged keys
			X11Forwarding = false;
			#Macs = [
				#"hmac-sha2-512-etm@openssh.com"
				#"hmac-sha2-256-etm@openssh.com"
				#"umac-128-etm@openssh.com"
				#"hmac-sha2-512"
			#];
		};
		allowSFTP = true;
		#openFirewall = true;  # Automatically open specified ports in the firewall
		ports = [ 42000 ];
		startWhenNeeded = false;  # sshd is socket-activated -- systemd starts an instance for each incoming connection instead of running the daemon

		# banner = "";  # Accepts strings concatenated with '\n'. Displayed to remote user before authentication is allowed
	};

	# ----- MOSH -----
	programs.mosh = {
		enable = true;
		openFirewall = false;
	};
}
