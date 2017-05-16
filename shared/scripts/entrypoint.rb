#!/usr/bin/env ruby

require "fileutils"

FileUtils.copy("/shared/dev_sudo_access", "/etc/sudoers.d/90-dev-user")

load("/shared/config.rb")

if $config[:redis]
  puts "Starting Redis"
  puts system("/etc/init.d/redis-server start")
end

if $config[:mysql]
  puts "Starting MySQL"
  puts system("/etc/init.d/mysql start")
end

if $config[:postgres]
  puts "Starting Postgres"

  FileUtils.remove(["/etc/postgresql/9.5/main/pg_hba.conf", "/etc/postgresql/9.5/main/postgresql.conf"])
  FileUtils.copy("/shared/postgres/pg_hba.conf", "/etc/postgresql/9.5/main/pg_hba.conf")
  FileUtils.copy("/shared/postgres/postgresql.conf", "/etc/postgresql/9.5/main/postgresql.conf")

  FileUtils.chown("postgres", "postgres", ["/etc/postgresql/9.5/main/pg_hba.conf", "/etc/postgresql/9.5/main/postgresql.conf"])

  puts system("/etc/init.d/postgresql start")
end

if $config[:elasticsearch]
  puts "Starting Elasticsearch"
  puts system("service elasticsearch start")
end

puts "Fixing SSH permissions"
File.chmod(0600, "/home/dev/.ssh/authorized_keys", "/home/dev/.ssh/config")
