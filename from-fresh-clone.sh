#!/usr/bin/env bash

# root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "SSH Host Key"
read hostkey

tee /etc/nixos/hostkeys.nix <<EOF
{
  users.users.root.openssh.authorizedKeys.keys = ["$hostkey"];
  users.users.vm.openssh.authorizedKeys.keys = ["$hostkey"];
}
EOF
git add -f hostkeys.nix

# generate hardware config
nixos-generate-config
git add -f hardware-configuration.nix

nixos-rebuild switch