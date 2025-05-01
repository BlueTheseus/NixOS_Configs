# Jellyfin is available by default on port:
# HTTP:  8096
# HTTPS: 8920

{ config, pkgs, ... }:

{
	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg
	];

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /srv/jellyfin 0750 jellyfin jellyfin"
	];

	# ----- SETTINGS -----
	services.jellyfin = {
		enable = true;
		# openFirewall = true;
		dataDir = "/srv/jellyfin";
	};

	# ----- JellySeer (optional) -----
	#services.jellyseer = {
		#enable = true;
		#port = 42690;
		#openFirewall = true;
	#};
}
