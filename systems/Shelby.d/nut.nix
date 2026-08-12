{config, pkgs, lib, ... }:
{

	# ----- UNINTERRUPTIBLE POWER SUPPLY -----
	# https://wiki.nixos.org/wiki/Uninterruptible_power_supply
	# https://www.jeffgeerling.com/blog/2025/nut-on-my-pi-so-my-servers-dont-die/
	# https://github.com/tucsonmesh/nixos-nuc/blob/main/ups.nix
	power.ups = {
		enable = true;
		mode = "standalone";
		#mode = "netserver";
		# section: The upsd UPS declarations: ups.conf
		# this UPS device is named UPS-1.
		ups."nutdev-usb1" = {
			description = "APC Back-UPS RS 1500MS2";

			# driver name from https://networkupstools.org/stable-hcl.html
			driver = "usbhid-ups";

			# usbhid-ups driver always use value "auto"
			port = "auto";

			# Info given from 'sudo nut-scanner -U'
			# vendorid = "051D";
			# productid = "0002";
			# product = "Back-UPS RS 1500MS2 FW:969.e4 .D USB FW:e4";
			# serial = "0B2617L16498";
			# vendor = "American Power Conversion";
			# bus = "001";
			# device = "002";
			# busport = "005";
			#summary = "\tvendorid = 051D\n\tproductid = 0002\n\tproduct = Back-UPS RS 1500MS2 FW:969.e4 .D USB FW:e4";

			directives = [
				"vendorid = \"051d\""
				"productid = \"0002\""
				"product = \"Back-UPS RS 1500MS2 FW:969.e4 .D USB FW:e4\""
				"serial = \"0B2617L16498\""
				"vendor = \"American Power Conversion\""
				# "bus = \"001\""
				# "device = \"002\""
				# "busport = \"005\""

				# "Restore power on AC" BIOS option needs power to
				# be cut a few seconds to work; this is achieved by
				# the offdelay and ondelay directives.

				# In the last stages of system shutdown, "upsdrvctl shutdown"
				# is called to tell UPS that after offdelay seconds, the UPS
				# power must be cut, even if wall power returns.

				# There is a danger that the system will take longer than the
				# default 20 seconds to shut down. If that were to happen,
				# the UPS shutdown would provoke a brutal system crash. We
				# adjust offdelay, to solve this issue.
				"offdelay = 180"

				# UPS power is now cut regardless of wall power. After
				# (ondelay minus offdelay) seconds, if wall power returns, turn
				# on UPS power. The system has now been disconnected for a
				# minimum of (ondelay minus offdelay) seconds,
				# "Restore power on AC" should now power on the system. For
				# reasons described above, ondelay value must be larger than
				# offdelay value. We adjust ondelay, to ensure Restore power on
				# AC option returns to Power Disconnected state.
				"ondelay = 70"

				# Set value for battery.charge.low,
				# upsmon initiate shutdown once this threshold is reached.
				"lowbatt = 40"

				# Ignore it if the UPS reports a low battery condition.
				# Without this, system will shutdown only when ups reports lb,
				# not respecting lowbatt option
				"ignorelb"
			];
			maxStartDelay = null;
		};
		upsd = {
			enable = true;
			listen = [
				#{ address = "0.0.0.0"; port = 3493; }
				#{ address = "::"; port = 3493; }
				#{ address = "127.0.0.1"; port = 3493; }
				{ address = "127.0.0.1"; }
				#{ address = "::1"; port = 3493; }
			];
		};
		users."nut-admin" = {
			passwordFile = "./ups-nut-admin-password.txt";
			actions = [ "set" "fsd" ];
			instcmds = [ "all" ];
			upsmon = "primary";
		};
		upsmon = {
			enable = true;
			monitor."nutdev-usb1" = {
				system = "nutdev-usb1@localhost";
				powerValue = 1;
				user = "nut-admin";
				passwordFile = "./ups-nut-admin-password.txt";
				type = "primary";
			};
			settings = {
				RUN_AS_USER = lib.mkForce "nut-admin";
				# This configuration file declares how upsmon is to handle
				# NOTIFY events.

				# POWERDOWNFLAG and SHUTDOWNCMD is provided by NixOS default
				# values

				# values provided by ConfigExamples 3.0 book
				NOTIFYMSG = [
					[ "ONLINE" ''"UPS %s: On line power."'' ]
					[ "ONBATT" ''"UPS %s: On battery."'' ]
					[ "LOWBATT" ''"UPS %s: Battery is low."'' ]
					[ "REPLBATT" ''"UPS %s: Battery needs to be replaced."'' ]
					[ "FSD" ''"UPS %s: Forced shutdown in progress."'' ]
					[ "SHUTDOWN" ''"Auto logout and shutdown proceeding."'' ]
					[ "COMMOK" ''"UPS %s: Communications (re-)established."'' ]
					[ "COMMBAD" ''"UPS %s: Communications lost."'' ]
					[ "NOCOMM" ''"UPS %s: Not available."'' ]
					[ "NOPARENT" ''"upsmon parent dead, shutdown impossible."'' ]
				];
				NOTIFYFLAG = [
					[ "ONLINE" "SYSLOG+WALL" ]
					[ "ONBATT" "SYSLOG+WALL" ]
					[ "LOWBATT" "SYSLOG+WALL" ]
					[ "REPLBATT" "SYSLOG+WALL" ]
					[ "FSD" "SYSLOG+WALL" ]
					[ "SHUTDOWN" "SYSLOG+WALL" ]
					[ "COMMOK" "SYSLOG+WALL" ]
					[ "COMMBAD" "SYSLOG+WALL" ]
					[ "NOCOMM" "SYSLOG+WALL" ]
					[ "NOPARENT" "SYSLOG+WALL" ]
				];
				# every RBWARNTIME seconds, upsmon will generate a replace
				# battery NOTIFY event
				RBWARNTIME = 216000; # 2.5 days is default?
				#RBWARNTIME = 126144000; # 4 years
				# every NOCOMMWARNTIME seconds, upsmon will generate a UPS
				# unreachable NOTIFY event
				NOCOMMWARNTIME = 300;
				# after sending SHUTDOWN NOTIFY event to warn users, upsmon
				# waits FINALDELAY seconds long before executing SHUTDOWNCMD
				# Some UPS's don't give much warning for low battery and will
				# require a value of 0 here for aq safe shutdown.
				FINALDELAY = 180;
			};
		};
	};
	users.users."nut-admin" = {
		isSystemUser = true;
		group = "nut-admin";
		home = "/var/lib/nut";
		createHome = true;
	};
	users.groups."nut-admin" = { };
	services.udev.packages = [ pkgs.nut ];

}
