# build without flakes:
#nix build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

# build without flakes | nixos-generators:
nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./iso.nix -o NIXOS-custom-$(date +%Y%m%d).iso"
