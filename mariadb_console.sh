#!/bin/sh

docker exec -it development-mariadb-1 /bin/bash -c "/usr/bin/mariadb -u root -p"
