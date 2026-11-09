# https://wiki.nixos.org/wiki/Printing
# https://www.systutorials.com/how-to-configure-scanner-in-a-hp-all-in-one-printer-on-linux/
{ config, pkgs, ... }:
{
	# ----- PRINTING -----
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			cups-filters
			cups-browsed
			hplipWithPlugin
		];
	};
	services.avahi = {
		enable = true;
		nssmdns4 = true;
		openFirewall = true; # UDP 5353
	};

	# ----- SCANNING -----
	environment.systemPackages = with pkgs; [
		sane-backends #................. SANE (Scanner Access Now Easy) backends
		sane-airscan #.................. Scanner Access Now Easy - Apple AirScan (eSCL) driver
		scanservjs #.................... SANE scanner nodejs web ui
		scantailor-universal #.......... Interactive post-processing tool for scanned pages
		simple-scan #................... Simple scanning utility
	];

}
