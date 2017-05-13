#!/bin/sh

docker run -d -P --name my-project --publish 1022:22 --publish 13000:3000 --publish 13306:3306 --publish 15432:5432 --restart=always rails-development-base
