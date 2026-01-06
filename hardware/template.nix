
{lib, pkgs, config, ...}:
{
	# ------------------------------ BATTERY ------------------------------
	# - Powertop ........ calibrates to best battery life, but least convenient
	# - TLP ............. most configurable
	# - Auto-CPUfreq .... decent?
	#
	# Not all configurations work together. Choose between the following
	# combinations:
	#
	# power-profiles daemon | powerManagement | Thermald | TLP | Auto-CPUfreq | Powertop
	# ----------------------|-----------------|----------|-----|--------------|---------
	#          x            |        x        |    x     |     |              |
	# ----------------------|-----------------|----------|-----|--------------|---------
	#          x            |        x        |    x     |  x  |              |
	# ----------------------|-----------------|----------|-----|--------------|---------
	#                       |        x        |    x     |     |      x       |
	# ----------------------|-----------------|----------|-----|--------------|---------
	#                       |                 |    x     |     |              |    x

	services.power-profiles-daemon.enable = false;
	powerManagement.enable = true;

	# ~ Thermald ~
	services.thermald.enable = true;

	# ~ TLP ~
	# Note: must disable services.power-profiles-daemon
	services.tlp = {
		enable = true;
		settings = {
			TLP_DEFAULT_MODE = "BAT";
			# DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wifi";
			# DEVICES_TO_ENABLE_ON_AC = "";
			# DEVICES_TO_DISABLE_ON_BAT = "bluetooth wifi";
			# DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi";
			USB_AUTOSUSPEND = 0;
			# USB_DENYLIST = "1111:2222 3333:4444";
			# USB_ALLOWLIST = "1111:2222 3333:4444";
			# USB_AUTOSUSPEND_DISBALE_ON_SHUTDOWN = 1;  # workaround if suspended USB devices disturb shutdown process
		};
	};

	# ~ Auto-CPUfreq ~
	# Note: do not enable alongside TLP or power-profiles-daemon--choose one.
	services.auto-cpufreq = {
		enable = false;
		settings = {
			battery = {
				governor = "powersave";
				turbo = "never";
			};
			charger = {
				governor = "performance";
				turbo = "auto";
			};
		};
	};

	# ~ Powertop ~
	# note: enable by itself. only cooperates with thermald
	# run powertop --calibrate
	powerManagement.powertop.enable = false;

	# ------------------------------ NVIDIA ------------------------------
	# https://wiki.archlinux.org/title/PRIME

	# Enable unfree repository for nvidia-x11, nvidia-settings, nvidia-persistenced
	nixpkgs.config = {
		allowUnfree = true;
		nvidia.acceptLicense = true;
	};

	# D-Bus service to check the availability of dual-GPU
	services.switcherooControl.enable = lib.mkDefault true;

	hardware = {
		graphics = {
			enable = lib.mkDefault true;
			enable32Bit = lib.mkDefault true;
			extraPackages = [
				pkgs.intel-media-driver
				pkgs.intel-compute-runtime
				(
					if pkgs ? libva-vdpau-driver
					then pkgs.libva-vdpau-driver
					else pkgs.vaapiVdpau
				)
			];
		};

		nvidia = {
			# Modesetting is required
			#modesetting.enable = true;

			# Nvidia power management. Experimental, and can cause sleep/suspend to fail.
			# Enable this if you have graphical corruption issues or application crashes after waking
			# up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
			# of just the bare essentials.
			powerManagement.enable = lib.mkDefault false;

			# Fine-grained power management. Turns off GPU when not in use.
			# Experimental and only works on modern Nvidia GPUs (Turing or newer).
			powerManagement.finegrained = lib.mkDefault true;

			# Use the NVidia open source kernel module (not to be confused with the
			# independent third-party "nouveau" open source driver).
			# Support is limited to the Turing and later architectures. Full list of 
			# supported GPUs is at: 
			# https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
			# Only available from driver 515.43.04+
			# Currently alpha-quality/buggy, so false is currently the recommended setting.
			open = false;

			# Enable the Nvidia settings menu,
			# accessible via `nvidia-settings`.
			nvidiaSettings = true;

			# Optionally, you may need to select the appropriate driver version for your specific GPU.
			package = config.boot.kernelPackages.nvidiaPackages.stable;
			#package = config.boot.kernelPackages.nvidiaPackages.beta;
			#package = config.boot.kernelPackages.nvidiaPackages.production;  # (installs 550)
			#package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
			#package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
			#package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
			#package = config.boot.kernelPackages.nvidiaPackages.legacy_340;

			# ----- Laptop Hybrid Graphics -----
			prime = {
				# Make sure to use the correct Bus ID values for your system!
				intelBusId  = lib.mkDefault "PCI:0:2:0"; #"PCI:0000:00:02.0";
				nvidiaBusId = lib.mkDefault "PCI:1:0:0"; #"PCI:0000:01:00.0";

				offload = {
					enable = lib.mkOverride 900 true;
					enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true; # Provides `nvidia-offload` command
				};

			# For people who want to use sync instead of offload
			#sync.enable = lib.mkOverride 990 true;
			};
		};
	};

	# Load nvidia driver for Xorg and Wayland
	services.xserver.videoDrivers = lib.mkDefault ["nvidia"];

	# ----- Disable NVIDIA GPU for Good Battery Life -----
	# boot.extraModprobeConfig = ''
	#   blacklist nouveau
	#   options nouveau modeset=0
	# '';

	# services.udev.extraRules = ''
	    # Remove NVIDIA USB xHCI Host Controller devices, if present
	#   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

	    # Remove NVIDIA USB Type-C UCSI devices, if present
	#   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

	    # Remove NVIDIA Audio devices, if present
	#   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

	    # Remove NVIDIA VGA/3D controller devices
	#   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"

	# '';
	# boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
}
