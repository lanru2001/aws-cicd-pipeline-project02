#!/bin/bash
# simple script to install Docker on RedHat Linux/CentOS

#Remove Podman container 
dnf remove -y podman buildah

#Install yum-utils package 
dnf install -y yum-utils
dnf install -y yum-utils 

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#Install the official latest community edition
dnf install -y docker-ce

sudo yum makecache

sudo dnf -y  install docker-ce --nobest

#Enable and start Docker Daemon
sudo systemctl start  docker
sudo systemctl enable docker

#Run docker with privilege without a sudo 
sudo usermod -aG docker $USER
