#!/bin/bash

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | sudo tee -a /etc/apt/sources.list.d/10gen.list

sudo apt-get update
sudo apt-get install -y python-software-properties git mongodb-10gen curl

cd /usr/local
wget http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-x86.tar.gz
sudo tar -xvzf node-v0.10.26-linux-x86.tar.gz --strip=1
rm -f node-v0.10.26-linux-x86.tar.gz

curl https://install.meteor.com | sudo sh
sudo npm install -g meteorite

#grunt-cli
sudo npm install -g grunt-cli

# sound-duel
# symlinks does not work, rsync-auto does not work
# rsync on every change manually
#mkdir /home/vagrant/meteor-local/
#rm -rf /vagrant/lib/core/app/.meteor/local
#sudo mount --bind /vagrant/ /home/vagrant/meteor-local/
cp -r /vagrant/ /home/vagrant/co-sound-local/
#sudo rsync -a -v /vagrant/ /home/vagrant/co-sound-local/