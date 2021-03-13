#!/bin/bash
yum update -y
yum install nginx -y
#cp /tmp/index.html /var/www/html/index.html
#chmod 755 /var/www/index.html
service nginx restart
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload

# install codedeploy agent on instance
yum install ruby -y

cd /tmp

wget https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/install;

chmod +x ./install

./install auto

service codedeploy-agent start
