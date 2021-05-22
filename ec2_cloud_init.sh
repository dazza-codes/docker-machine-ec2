#!/usr/bin/env bash

# export UBUNTU_CODE=$(lsb_release -c)

sudo apt update
sudo apt upgrade -y
sudo apt install -y \
    build-essential \
    curl \
    git \
    gnupg2 \
    locales \
    pass \
    software-properties-common \
    unzip \
    wget

#
# Install miniconda
#
curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sudo mkdir /opt/conda
sudo chown -R ubuntu:ubuntu /opt/conda
/usr/bin/env bash miniconda_installer.sh -b -f -u -p /opt/conda
rm ./miniconda_installer.sh
source /opt/conda/etc/profile.d/conda.sh
conda update -y -n base -c defaults conda
sudo mkdir -p /etc/profile.d
sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
echo "source /opt/conda/etc/profile.d/conda.sh" >> ${HOME}/.bashrc

#
# Install poetry
#
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
source $HOME/.poetry/env
poetry --version

#
# Install awscli v2
#
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
/usr/local/bin/aws --version
# the following modifies the [default] profile config in ~/.aws/config;
# apply this to any other profiles in use
/usr/local/bin/aws configure set default.s3.max_concurrent_requests 200
/usr/local/bin/aws configure set default.s3.max_queue_size 10000


#
# Install jq (JSON Query)
#
curl -o jq-linux64 -sSL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
mv jq-linux64 /usr/local/bin/jq
chmod a+x /usr/local/bin/jq
jq --version


#
# Install docker and get `docker run hello-world` working on the box.
#
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
cat /etc/lsb-release
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker $USER
# docker run hello-world
# docker system prune -a
# docker login registry.gitlab.com

 
#
# Install docker-compose
#
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


#
# Add postgresql and postgis
#
sudo apt-get install -y postgresql postgresql-client postgis libpq-dev libpqxx-dev
# if postgres is not required to be running:
sudo systemctl stop postgresql
sudo systemctl disable postgresql
 
#
# Add Gnu Parallel
# https://www.gnu.org/software/parallel/
#
sudo apt-get install -y parallel
