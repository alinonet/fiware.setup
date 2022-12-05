#!/bin/bash

## Installation of dependency packages
sudo apt-get install -y aptitude

## Tools for compilation and testing:
sudo aptitude install -y build-essential scons curl cmake

## Dependency libraries that aren't built from source code:
sudo aptitude install -y libssl-dev gnutls-dev libcurl4-gnutls-dev libsasl2-dev \
                         libgcrypt-dev uuid-dev libboost1.67-dev libboost-regex1.67-dev libboost-thread1.67-dev \
                         libboost-filesystem1.67-dev libz-dev libmongoclient-dev
export GROUP=ubuntu
mkdir ~/git
sudo aptitude install -y git

## Mongo C driver
sudo mkdir /opt/mongoc
sudo chown $USER:$GROUP /opt/mongoc
cd /opt/mongoc
wget https://github.com/mongodb/mongo-c-driver/releases/download/1.22.0/mongo-c-driver-1.22.0.tar.gz
tar xzf mongo-c-driver-1.22.0.tar.gz
cd mongo-c-driver-1.22.0
mkdir cmake-build
cd cmake-build
cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF ..
cmake --build .
sudo cmake --build . --target install

## libmicrohttpd
sudo mkdir /opt/libmicrohttpd
sudo chown $USER:$GROUP /opt/libmicrohttpd
cd /opt/libmicrohttpd
wget http://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.75.tar.gz
tar xvf libmicrohttpd-0.9.75.tar.gz
cd libmicrohttpd-0.9.75
./configure --disable-messages --disable-postprocessor --disable-dauth
make
sudo make install

## rapidjson
sudo mkdir /opt/rapidjson
sudo chown $USER:$GROUP /opt/rapidjson
cd /opt/rapidjson
wget https://github.com/miloyip/rapidjson/archive/v1.0.2.tar.gz
tar xfvz v1.0.2.tar.gz
sudo mv rapidjson-1.0.2/include/rapidjson/ /usr/local/include

## k-libs
cd ~/git
for k in kbase klog kalloc kjson khash
do
  git clone https://gitlab.com/kzangeli/$k.git
done

for k in kbase klog kalloc khash
do
  cd $k
  git checkout release/0.8
  make install
  cd ..
done

cd kjson
git checkout release/0.8.2
make install

## MQTT (Paho MQTT)
sudo aptitude install -y doxygen
sudo aptitude install -y graphviz
sudo rm -f /usr/local/lib/libpaho*
cd ~/git
git clone https://github.com/eclipse/paho.mqtt.c.git
cd paho.mqtt.c
git checkout tags/v1.3.10
make html
make
sudo make install

## Python paho-mqtt library
sudo aptitude install -y python3-pip
pip3 install paho-mqtt

## Prometheus C Client Library
cd ~/git
git clone https://github.com/digitalocean/prometheus-client-c.git
cd prometheus-client-c
git checkout release-0.1.3
sed 's/\&promhttp_handler,/(MHD_AccessHandlerCallback) \&promhttp_handler,/' promhttp/src/promhttp.c > XXX
mv XXX promhttp/src/promhttp.c
./auto build

## Postgres development libraries
sudo apt-get install -y libpq-dev

## Compiling Orion-LD from source code
cd ~/git
# git clone https://github.com/FIWARE/context.Orion-LD
# cd context.Orion-LD
wget https://github.com/FIWARE/context.Orion-LD/archive/refs/tags/1.1.1.tar.gz
tar -xf 1.1.1.tar.gz
rm 1.1.1.tar.gz
cd context.Orion-LD-1.1.1

sudo touch /usr/bin/orionld
sudo chown $USER:$GROUP /usr/bin/orionld
sudo touch /etc/init.d/orionld
sudo chown $USER:$GROUP /etc/init.d/orionld
sudo touch /etc/default/orionld
sudo chown $USER:$GROUP /etc/default/orionld
make install
make di   # "di" is a make target that does "debug install"

# The Prometheus lib is a shared library (well, two libraries) and in a "weird" place, so for that we will need to use LD_LIBRARY_PATH:
export LD_LIBRARY_PATH=~/git/prometheus-client-c/prom/build:~/git/prometheus-client-c/promhttp/build

## Eclipse Mosquitto
sudo aptitude install -y mosquitto
sudo systemctl start mosquitto
sudo systemctl enable mosquitto

## Postgres 12
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list

sudo apt update
sudo apt -y install postgresql-12 postgresql-client-12
sudo apt install -y postgis postgresql-12-postgis-3
sudo apt-get install -y postgresql-12-postgis-3-scripts

## Add timescale db and postgis
sudo add-apt-repository ppa:timescale/timescaledb-ppa
sudo apt-get update
sudo apt install -y timescaledb-postgresql-12

## Enable postgres
sudo systemctl enable postgresql

echo Add this line at the end of the file and save it
echo
echo shared_preload_libraries = 'timescaledb'
echo
echo Press Enter to continue...
read key
sudo nano /etc/postgresql/12/main/postgresql.conf

## Restart Postgres
sudo /etc/init.d/postgresql restart

## Create the Postgres user for Orion-LD
echo "Enter psql interactive shell:"
echo ""
echo "psql"
echo "ALTER USER postgres WITH PASSWORD 'password';"
echo "\q"
echo "logout"
echo ""
echo "Press Enter to continue..."
read key
sudo su - postgres

## MongoDB
sudo aptitude install -y gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo aptitude update
sudo aptitude install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
