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

# sound-duel
mkdir /home/vagrant/meteor-local/
rm -rf /vagrant/app/.meteor/local
ln -s /home/vagrant/meteor-local /vagrant/lib/core/app/.meteor/local
