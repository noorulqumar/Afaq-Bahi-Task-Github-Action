#!/usr/bin/bash
set -x
eval "$(ssh-agent -s)"
ssh-add - <<< "$PRIVATE_KEY"
ssh -o StrictHostKeyChecking=no ubuntu@51.20.144.90 
echo 'SSH connection successful'
if command -v docker &>/dev/null; then
    echo "Docker is installed."
else
    echo "Docker is not installed."
    sudo apt update -y
    sudo apt install docker.io -y
    sudo usermod -aG docker "$USER"
    echo "$USER"
    newgrp docker
    sleep 10
    sudo systemctl start docker
fi

docker images
if command -v awscli &>/dev/null
then
    if (( $? !=  0 ))
    then
        echo "installing AWSCLI"
        sudo apt update
        sudo apt  install awscli -y
    else
        echo "awscli is installed"
    fi
fi
echo "hello"
aws configure set aws_access_key_id "$ACCESS_KEY"
aws configure set aws_secret_access_key "$SECRET_KEY"
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 294894169523.dkr.ecr.eu-north-1.amazonaws.com
docker rm -f "$(docker ps -aq)"
docker run -d -p 80:80 294894169523.dkr.ecr.eu-north-1.amazonaws.com/test-repo-1:23
