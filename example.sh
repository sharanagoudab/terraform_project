#!/bin/bash

sudo apt-get update
sudo apt-get install apache2 -y

sudo mkdir /home/ubuntu/demo-test.txt
git clone https://github.com/amolshete/card-website.git
cp -rf card-website/* /var/www/html