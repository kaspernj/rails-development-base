#!/usr/bin/env ruby

require "fileutils"

FileUtils.copy("/shared/dev_sudo_access", "/etc/sudoers.d/90-dev-user")

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
