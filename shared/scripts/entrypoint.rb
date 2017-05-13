#!/usr/bin/env ruby

config = load("/shared/config.rb")

if config[:redis]
  puts "Starting Redis"
  `/etc/init.d/redis-server restart`
end

if config[:mysql]
  puts "Starting MySQL"
  load "/shared/scripts/setup_mysql"
end

if config[:postgres]
  puts "Starting Postgres"
  load "/shared/scripts/setup_postgres"
end

puts "Starting clone and deploy"
load "/shared/scripts/clone_and_deploy"
