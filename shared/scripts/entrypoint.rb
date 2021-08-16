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

  if File.exist?("/etc/postgresql/9.5")
    postgres_version = "9.5"
  elsif File.exist?("/etc/postgresql/9.6")
    postgres_version = "9.6"
  else
    raise "Could not figure out Postgrs version"
  end

  File.unlink("/etc/postgresql/#{postgres_version}/main/pg_hba.conf") if File.exists?("/etc/postgresql/#{postgres_version}/main/pg_hba.conf")
  File.unlink("/etc/postgresql/#{postgres_version}/main/postgresql.conf") if File.exists?("/etc/postgresql/#{postgres_version}/main/postgresql.conf")

  FileUtils.copy("/shared/postgres/#{postgres_version}/pg_hba.conf", "/etc/postgresql/#{postgres_version}/main/pg_hba.conf")
  FileUtils.copy("/shared/postgres/#{postgres_version}/postgresql.conf", "/etc/postgresql/#{postgres_version}/main/postgresql.conf")

  FileUtils.chown("postgres", "postgres", ["/etc/postgresql/#{postgres_version}/main/pg_hba.conf", "/etc/postgresql/#{postgres_version}/main/postgresql.conf"])

  puts system("/etc/init.d/postgresql restart")
end

if $config[:elasticsearch]
  puts "Starting Elasticsearch"
  puts system("service elasticsearch start")
end

unless File.exists?("/home/dev/.ssh")
  puts "Preparing home dir"
  FileUtils.chown("dev", "dev", "/home/dev")
  system("find", "/home/dev-sample/", "-mindepth", "1", "-maxdepth", "1", "-exec", "cp", "-rp", "{}", "/home/dev/", ";")
end

puts "Fixing SSH permissions"
FileUtils.chown("dev", "dev", ["/home/dev/.ssh/authorized_keys", "/home/dev/.ssh/config"])
File.chmod(0600, "/home/dev/.ssh/authorized_keys") if File.exists?("/home/dev/.ssh/authorized_keys")
File.chmod(0600, "/home/dev/.ssh/config") if File.exists?("/home/dev/.ssh/config")

puts "Installing SSHD config"
File.unlink("/etc/ssh/sshd_config") if File.exists?("/etc/ssh/sshd_config")

unless File.exists?("/shared/ssh/sshd_config")
  puts "Copying sample SSHD config since none exists"
  FileUtils.copy("/shared/ssh/sshd_config.example", "/shared/ssh/sshd_config")
end

unless File.exists?("/shared/ssh/config")
  puts "Copying sample SSH config since none exists"
  FileUtils.copy("/shared/ssh/config.example", "/shared/ssh/config")
end

FileUtils.copy("/shared/ssh/sshd_config", "/etc/ssh/sshd_config")

compose_environment_file_path = "/shared/profile"

if File.exists?(compose_environment_file_path)
  puts "Installing custom profile"

  profile_path = "/home/dev/.profile"
  FileUtils.touch(profile_path) unless File.exists?(profile_path)
  profile_content = File.read(profile_path)

  unless profile_content.include?(". #{compose_environment_file_path}")
    profile_content << "\n\n. #{compose_environment_file_path}"
    File.open(profile_path, "w") do |fp|
      fp.write(profile_content)
    end
  end
end

File.chmod(0600, "/etc/ssh/sshd_config")
