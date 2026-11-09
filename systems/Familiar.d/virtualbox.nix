{ config, ... }:
let
	USER = "Xenia";
in {
	# ----- VIRTUALBOX -----
	virtualisation.virtualbox = {
		host = {
			enable = true;
			enableExtensionPack = false; # Enabling this results in compiling from source, which is slow and resource-intensive
		};
	};
	users.extraGroups.vboxusers.members = [ "${USER}" ];
	boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # temp fix: https://discourse.nixos.org/t/issue-with-virtualbox-in-24-11/57607
}
