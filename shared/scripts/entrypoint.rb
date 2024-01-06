#!/usr/bin/env ruby

require "fileutils"

FileUtils.copy("/shared/dev_sudo_access", "/etc/sudoers.d/90-dev-user")

unless File.exists?("/home/dev/.ssh")
  puts "Preparing home dir"
  FileUtils.chown("dev", "dev", "/home/dev")
  system("find", "/home/dev-sample/", "-mindepth", "1", "-maxdepth", "1", "-exec", "cp", "-rp", "{}", "/home/dev/", ";")
end

unless File.exists?("/shared/ssh/authorized_keys")
  puts "Copying sample authorized_keys since none exists"
  FileUtils.copy("/shared/ssh/authorized_keys.example", "/shared/ssh/authorized_keys")
end

puts "Fixing SSH permissions"
FileUtils.chown("dev", "dev", ["/home/dev/.ssh/authorized_keys", "/home/dev/.ssh/config"])
File.chmod(0600, "/home/dev/.ssh/authorized_keys") if File.exists?("/home/dev/.ssh/authorized_keys")
File.chmod(0600, "/home/dev/.ssh/config") if File.exists?("/home/dev/.ssh/config")

puts "Installing SSHD config"

unless File.exists?("/shared/ssh/sshd_config")
  puts "Copying sample SSHD config since none exists"
  FileUtils.copy("/etc/ssh/sshd_config.original", "/shared/ssh/sshd_config")
end

File.unlink("/etc/ssh/sshd_config") if File.exists?("/etc/ssh/sshd_config")

unless File.exists?("/shared/ssh/config")
  puts "Copying sample SSH config since none exists"
  FileUtils.copy("/shared/ssh/config.example", "/shared/ssh/config")
end

shared_sshd_file_path = "/shared/ssh/sshd_config"
etc_sshd_file_path = "/etc/ssh/sshd_config"

if !File.exists?(etc_sshd_file_path) || File.size(shared_sshd_file_path) != File.size(etc_sshd_file_path)
  puts "Copying #{shared_sshd_file_path} to #{etc_sshd_file_path}"
  FileUtils.copy(shared_sshd_file_path, etc_sshd_file_path)
end

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
