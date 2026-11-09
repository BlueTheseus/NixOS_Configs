{ config, pkgs, ... }:
let
	USER = "Xenia";
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
