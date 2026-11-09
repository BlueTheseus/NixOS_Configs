{ config, pkgs, ... }:
let
	USER = "";
in {
	# ----- SYNCTHING -----
	systemd.services."syncthingd" = {
		script = ''#!${pkgs.runtimeShell} syncthing'';
		serviceConfig = {
			Type = "oneshot";
			User = "${USER}";
		};
	};
}
