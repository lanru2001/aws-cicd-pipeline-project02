#!/bin/bash
yum update -y
yum install nginx -y
#cp /tmp/index.html /var/www/html/index.html
#chmod 755 /var/www/index.html
systemctl start nginx.service

# install codedeploy agent on instance
yum install ruby -y 
yum install wget -y
cd /tmp
wget https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/install;
chmod +x ./install
./install auto
systemctl start codedeploy-agent
