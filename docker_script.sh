#!/bin/bash
# simple script to install Docker on RedHat Linux/CentOS
dnf remove -y podman buildah

dnf install -y yum-utils

dnf install -y yum-utils

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y docker-ce

sudo yum makecache

sudo dnf -y  install docker-ce --nobest

sudo systemctl enable --now docker

systemctl status  docker

sudo usermod -aG docker $USER
