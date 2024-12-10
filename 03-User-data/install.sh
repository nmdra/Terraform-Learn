#!/bin/bash
apt-get update
apt-get install nginx -y
echo "Nimendra" >/var/www/html/index.nginx-debian.html