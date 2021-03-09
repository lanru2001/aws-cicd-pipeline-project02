#!/bin/bash
yum update -y
yum install apache2 -y
cp /tmp/index.html /var/www/html/index.html
chmod 755 /var/www/index.html
service apache2 restart
