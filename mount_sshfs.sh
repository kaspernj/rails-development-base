#!/bin/sh

sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,port=1022 dev@container.dev:/home/dev/project /Users/username/Dev/project
