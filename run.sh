#!/bin/bash

# Remove currently running container
sudo docker rm -f cs

# Create a container but do not initialize it
sudo docker create -p 27015:27015/udp \
    -e START_MAP="`cat config/startmap`" \
    -e ADMIN_STEAM="`cat config/admins`" \
    -e SERVER_NAME="`cat config/servername`" \
    --name cs hlds/server:alpha +log

# Add rcon password
sudo docker cp cs:/opt/hlds/cstrike/server.cfg server.cfg.tmp
sudo sh -c 'printf "\nrcon_password '"`cat config/rconpassword`"'" >> server.cfg.tmp'
sudo docker cp server.cfg.tmp cs:/opt/hlds/cstrike/server.cfg
sudo rm server.cfg.tmp

# Add podbot addon to metamod config
sudo docker cp cs:/opt/hlds/cstrike/addons/metamod/plugins.ini plugins.ini.tmp
sudo sh -c 'echo "linux addons/podbot/podbot_mm_i386.so" >> plugins.ini.tmp'
sudo docker cp plugins.ini.tmp cs:/opt/hlds/cstrike/addons/metamod/plugins.ini
sudo rm plugins.ini.tmp

# Add extra maps and files
cd extra_files
for file in `ls -1`; do
sudo docker cp $file cs:/opt/hlds/cstrike
done

# Start the container
sudo docker start cs
