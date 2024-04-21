#!/usr/bin/env bash

# stop script if template not substituted
if [[ "template" -eq "template" ]]
  then echo "Can't run without template substitution"
  exit
fi

# root check
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

git config --global user.name "<gitname>"
git config --global user.email "<gitemail>"
git clone <giturl> /etc/nixos

tee /etc/nixos/hostkeys.nix <<EOF
{
  users.users.root.openssh.authorizedKeys.keys = ["<hostkey>"];
  users.users.vm.openssh.authorizedKeys.keys = ["<hostkey>"];
}
EOF
git add -f hostkeys.nix

# generate hardware config
nixos-generate-config
git add -f hardware-configuration.nix

nixos-rebuild switch