# Jellyfin is available by default on port:
# HTTP:  8096
# HTTPS: 8920

{ config, pkgs, lib, ... }:

{
	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg
	];

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /srv/jellyfin 0700 jellyfin jellyfin"
	];

	# ----- SETTINGS -----
	services.jellyfin = {
		enable = true;
		openFirewall = false;
		dataDir = "/srv/jellyfin";
	};

	# The following line clears Jellyfin's "wantedBy" setting for its
	# systemd service. This means Jellyfin won't start automatically
	# at boot and must be manually started with the command
	# 'systemctl start jellyfin.service' . This is handy for when you
	# don't want to start the service until you manually mount or
	# decrypt its data directory.
	#systemd.services.jellyfin.wantedBy = lib.mkForce [];

	# ----- JellySeer (optional) -----
	#services.jellyseer = {
		#enable = true;
		#port = 42690;
		#openFirewall = true;
	#};
}
