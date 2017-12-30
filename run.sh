#!/bin/sh

docker run -d -P \
  --name my-project \
  --publish 1022:22 \
  --restart=always \
  -v /path/to/shared:/shared \
  rails-development-base
