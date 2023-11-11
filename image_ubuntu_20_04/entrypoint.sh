#!/bin/sh

echo Starting container
ruby /shared/scripts/entrypoint.rb > /shared/log/last_startup

echo Starting SSH daemon
/usr/sbin/sshd -D > /var/log/sshd.log
