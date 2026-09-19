#!/bin/sh

echo Starting container
ruby /shared/scripts/entrypoint.rb > /shared/log/last_startup

ensure_shared_link() {
  target=$1
  link=$2

  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" != "$target" ]; then
      echo "Preserving existing symlink at $link; expected target $target." >&2
    fi
  elif [ -e "$link" ]; then
    echo "Preserving existing path at $link; expected symlink to $target." >&2
  else
    runuser -u dev -- ln -s "$target" "$link"
  fi
}

install -d -m 0700 -o dev -g dev /home/dev/.dsh
install -d -m 0755 -o dev -g dev /home/dev/.agents
ensure_shared_link /opt/ai-prompts/AGENTS.md /home/dev/.dsh/AGENTS.md
ensure_shared_link /opt/opencode-shared/deepseek-harness/cordis.patch.yml /home/dev/.dsh/cordis.patch.yml
ensure_shared_link /opt/opencode-shared/local/deepseek-harness.env /home/dev/.dsh/.env
ensure_shared_link /opt/ai-prompts/skills /home/dev/.agents/skills

echo Starting SSH daemon
/usr/sbin/sshd -D
