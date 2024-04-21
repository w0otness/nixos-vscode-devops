#!/usr/bin/env bash

echo "Enter SSH Host Pub key"
read hostkey

echo "Git URL for Config"
read giturl

echo "Git Name"
read gitname

echo "Git Email"
read gitemail

# backup if hostkeys.nix exist
if [[ -f "hostkeys.nix" ]]; then
  mv hostkeys.nix hostkeys.nix.bak
fi

# write hostkeys.nix and add to git so nix build can see it
tee hostkeys.nix << END
{
  users.users.root.openssh.authorizedKeys.keys = ["$hostkey"];
  users.users.vm.openssh.authorizedKeys.keys = ["$hostkey"];
}
END
git add -f hostkeys.nix

# uncomment bootstrap, comment hardware config
sed -i 's_#./bootstrap.nix_./bootstrap.nix_g' configuration.nix
sed -i 's_./hardware-configuration.nix_#./hardware-configuration.nix_g' configuration.nix

# put variables into bootstrap.sh and enable
sed -i 's_<hostkey>_'"$hostkey"'_g' bootstrap.sh
sed -i 's_<giturl>_'"$giturl"'_g' bootstrap.sh
sed -i 's_<gitname>_'"$gitname"'_g' bootstrap.sh
sed -i 's_<gitemail>_'"$gitemail"'_g' bootstrap.sh
sed -i 's_"template" -eq "template"_"template" -ne "template"_g' bootstrap.sh

# build ova
nix build .#generate-ova

# if success add hostkey name suffix to ova and remove result link
if [ $? == 0 ]; then
  for file in ./result/*.ova; do
    cp -H $file $( sed "s_/result__g" <<<"$( sed "s_.ova_-$(echo $hostkey | grep -oE "[^ ]+$").ova_g" <<<"$file" )" )
  done
  unlink result
fi

# revert bootstrap to avoid commit
git restore bootstrap.sh

# revert comments
sed -i 's_./bootstrap.nix_#./bootstrap.nix_g' configuration.nix
sed -i 's_#./hardware-configuration.nix_./hardware-configuration.nix_g' configuration.nix

# restore backup
if [[ -f "hostkeys.nix.bak" ]]; then
  mv -f hostkeys.nix.bak hostkeys.nix
fi
