#!/bin/sh

sshfs -o reconnect,noappledouble,ServerAliveInterval=15,ServerAliveCountMax=3,port=1022 dev@container.dev:/home/dev/Development /Users/username/Dev/project
