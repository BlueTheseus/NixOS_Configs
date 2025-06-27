{ pkgs, ... }:

{
	imports = [ ./desktop-packages.nix ];

	# ----- KDE PLASMA -----
	services = {
		displayManager = {
			defaultSession = "plasma";
			sddm = {
				enable = true;
				wayland.enable = true;
			};
		};
		desktopManager.plasma6.enable = true;
	};
	
	
	# ----- QT CONFIGURATION -----
	qt = {
		enable = true;
		#platformTheme = "gnome";
		#style = "adwaita-dark";
	};
	
	# ----- PACKAGES -----
	nixpkgs.config.packageOverrides = pkgs: { # Enable the Nix Users Repository
		nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
			inherit pkgs;
		};
	};

	# ~ Extra Packages ~
	environment.systemPackages = with pkgs; [
		#kdePackages.bluedevil #.............. adds bluetooth capabilities to KDE Plasma
		kdePackages.bluez-qt #............... Qt wrapper for Bluez 5 DBus API -- for bluetooth control in kde settings
		kdePackages.krohnkite
		nur.repos.shadowrz.klassy-qt6
		qpwgraph #........................... QT-based pipewire manager
		typstwriter #........................ Editor for the typst formatting language
	];
	
	# ~ Exclude Packages ~
	#environment.plasma6.excludePackages = with pkgs.kdePackages; [
		#plasma-browser-integration
		#konsole
		#oxygen
	#]
}
