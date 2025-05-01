{ pkgs, ... }:

{
	imports = [ ./Desktop_Packages.nix ];

	# ----- X11 and Gnome -----
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
	
	
	# ----- QT Configuration -----
	qt = {
		enable = true;
		#platformTheme = "gnome";
		#style = "adwaita-dark";
	};
	
	# ----- Extra Packages -----
	environment.systemPackages = with pkgs; [
		qpwgraph #..... QT-based pipewire manager
	];
	
	# Exclude select default KDE Plasma applications
	#environment.plasma6.excludePackages = with pkgs.kdePackages; [
		#plasma-browser-integration
		#konsole
		#oxygen
	#]
}
