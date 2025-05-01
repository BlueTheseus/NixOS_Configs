# https://github.com/jelmer/xandikos
# https://mynixos.com/nixpkgs/options/services.xandikos

{ ... }:
{
	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		"d /srv/xandikos 0750 root users"
	];

	# ----- SETTINGS -----
	services.xandikos = {
		enable = true;
		#address = [];
		port = 43000;
		routePrefix = "/srv/xandikos/";
		#nginx = {
			#enable = true;
			#hostName = "";
		#};
		#extraOptions = [ "--autocreate" "--defaults" "--current-user-principal user" "--dump-dav-xml" ];
	};
}
