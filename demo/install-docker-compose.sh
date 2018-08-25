#!/bin/bash
#this will setup docker-compose on a coreOS (or similar) box
# use sudo ./install-docker.compose.sh
mkdir -p /opt/bin
curl -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose
