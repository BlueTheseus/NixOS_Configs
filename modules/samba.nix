{ config, pkgs, ... }:
{
	# ----- PACKAGES -----
	environment.systemPackages = with pkgs; [
		#cifs-utils  # makes mounting samba shares from cli easier
		samba
	];

	# ----- SYSTEM -----
	systemd.tmpfiles.rules = [
		# "d /folder/to/create <chmod-value> <user> <group>"
		"d /srv/samba         755 root users"
		"d /srv/samba/Portal  755 root users"
		"d /srv/samba/School  755 root users"
		"d /srv/samba/Library 755 root users"
	];

	# ----- SETTINGS -----
	services.samba = {
		enable = true;
		openFirewall = true;
		# syncPasswordsByPam = true;  # ?
		settings = {
			global = {
				#"workgroup" = "WORKGROUP";
				"use sendfile" = "yes";
				"guest account" = "nobody";
				"map to guest" = "bad user";
				"follow symlinks" = "yes";
				#"aio read size" = 1;
				#"aio write size" = 1;
				"inherit permissions" = "yes";
				security = "user";
				#"client ipc max protocol" = "SMB3";
				"client ipc min protocol" = "SMB2_10";
				#"client max protocol" = "SMB3";
				"client min protocol" = "SMB2_10";
				#"server max protocol" = "SMB3";
				"server min protocol" = "SMB2_10";
				"max log size" = "1000";
				# ----- Apple Device Compatability -----
				"vfs objects" = "fruit streams_xattr catia acl_xattr";
				"fruit:aapl" = "yes";
				#"fruit:advertise_fullsync";
				"fruit:metadata" = "stream";
				"fruit:model" = "MacSamba"; # MacPro7,1 or MacSamba
				"fruit:posix_rename" = "yes";
				"fruit:veto_appledouble" = "no";
				"fruit:nfs_aces" = "no";
				"fruit:wipe_intentioanlly_left_blank_rfork" = "yes";
				"fruit:delete_empty_adfiles" = "yes";
			};
			#public = {
				#path = "/mnt/Shares/Public";
				#browseable = "yes";
				#"read only" = "no";

				# Public - Allow Anyone
				#"guest ok" = "yes";
				#"force user" = "nobody";
				#"force group" = "users";
				#"create mask" = "0644";
				#"directory mask" = "0755";
				#"force user" = "username";
				#"force group" = "groupname";

				# "veto files" = "";
				# "delete veto files" = "yes";
			#};

			#private = {
				#path = "/mnt/Shares/Private";
				#browseable = "yes";
				#"read only" = "no";

				# Private - Must provide valid login
				#"guest ok" = "no";
				#"valid users" = "";
				#"create mask" = "0644";
				#"directory mask" = "0755";
				#"force user" = "username";
				#"force group" = "groupname";

				# "veto files" = "";
				# "delete veto files" = "yes";
			#};
		};
	};
	# directory /var/lib/samba/private must be accessible by samba (root) for smbpasswd
	#networking.firewall.allowedTCPPorts = [ 445 139 ];
	#networking.firewall.allowedUDPPorts = [ 137 138 ];
	#services.avahi = {
		#enable = true;
		#nssmdns = true;
		#publish = {
			#enable = true;
			#addresses = true;
			#domain = true;
			#hinfo = true;
			#userServices = true;
			#workstation = true;
		#};
		#extraServiceFiles = {
		#smb = ''
			#<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
			#<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
			#<service-group>
				#<name replace-wildcards="yes">%h</name>
				#<service>
					#<type>_smb._tcp</type>
					#<port>445</port>
				#</service>
			#</service-group>
		#'';
		#};
	#};
}
