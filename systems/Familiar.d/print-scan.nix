{ config, pkgs, ... }:
{
	services.ipp-usb.enable = true;
	# Network Printing / Scanning
	services.avahi = {
		enable = true;
		nssmdns4 = true; # IPv4
		nssmdns6 = true; # IPv6
		openFirewall = true; # UDP 5353
	};

	# ----- PRINTING -----
	# https://wiki.nixos.org/wiki/Printing
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			cups-filters
			cups-browsed
			hplipWithPlugin
		];
	};

	# ----- SCANNING -----
	# https://wiki.nixos.org/wiki/Scanners
	# https://www.systutorials.com/how-to-configure-scanner-in-a-hp-all-in-one-printer-on-linux/
	hardware.sane = {
		enable = true;
		extraBackends = with pkgs; [
			hplipWithPlugin
			sane-airscan
		];
		#disabledDefaultBackends = [ "escl" ];
	};
	services.udev.packages = with pkgs; [ sane-airscan ];
	systemd.services.my-scan-service.environment = {
		SANE_CONFIG_DIR = "/etc/sane-config";
		LD_LIBRARY_PATH = "/etc/sane-libs";
	};
	environment.systemPackages = with pkgs; [
		#sane-backends #................ SANE (Scanner Access Now Easy) backends
		scantailor-universal #.......... Interactive post-processing tool for scanned pages
		simple-scan #................... Simple scanning utility
	];

}
