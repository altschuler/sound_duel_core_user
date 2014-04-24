#!/bin/bash
mkdir /home/vagrant/meteor-local/
rm -rf /vagrant/app/.meteor/local
ln -s /home/vagrant/meteor-local/ /vagrant/app/.meteor/local
