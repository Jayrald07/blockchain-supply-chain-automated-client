#!/bin/bash
# Title: Chaindirect Client
# Created By: Jayrald B. Empino

VERSION="v1.0"

if [ "$DEV" = "dev" ]; then
  VERSION=dev
fi

if [ -x "$(command -v docker)" ]; then

  echo "Docker detected"

else
  
  apt-get update
  apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  apt-get update
  apt-get install -y docker-ce
  usermod -aG docker ubuntu
  newgrp docker

  if [ -x "$(command -v docker)" ]; then
    echo "Docker is now installed"
  else
    echo "Docker installation failed"
    exit 0
  fi

fi

echo "Proceeding pulling chaindirect client image"

docker pull chaindirect/client:$VERSION



echo " "



docker run -d --net host --restart always --name client -v /var/run/docker.sock:/var/run/docker.sock chaindirect/client:$VERSION

echo " "

interfaces=( $(ip -o link show | awk -F': ' '{print $2}') )

echo -e "\033[1mSetup your node: \033[0m"

for i in "${interfaces[@]}"
do
    if ! ip link show "$i" &> /dev/null; then
        continue
    fi
    
    IP_ADDRESS=$(ip -o -4 addr show dev "$i" | awk '{split($4,a,"/"); print a[1]}')
    
    if [ -z "$IP_ADDRESS" ]; then
        continue
    fi
    
    echo -e "\033[32mhttp://$IP_ADDRESS\033[0m"
done
