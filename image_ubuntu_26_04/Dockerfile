FROM ubuntu:26.04

ARG CLAUDE_CODE_VERSION=2.1.236
ARG CODEX_VERSION=0.153.4
ARG KIMI_CODE_VERSION=0.41.0
ARG OPENCODE_VERSION=1.18.29
ARG QWEN_CODE_VERSION=0.23.3

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PATH=/home/dev/.local/bin:$PATH
ENV DEBIAN_FRONTEND=noninteractive

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ADD qwen-code-launcher /usr/local/bin/qwen
ADD apt-preferences-d-firefox /etc/apt/preferences.d/mozilla-firefox

# Auto install Rubies
COPY .rvmrc /tmp/dev.rvmrc

RUN chmod +x /usr/local/bin/entrypoint.sh && \
  apt-get update && apt-get install -y --force-yes apt-utils wget curl && apt-get clean && \

# Locale install
  apt-get update && apt-get install -y --force-yes locales && apt-get clean && \
  locale-gen "en_US.UTF-8" && \

# Postgres tools
  apt-get update && apt-get install -y --force-yes postgresql-client && \
  apt-get clean && \

# Install base apps and packages
  apt-get update && apt-get install -y --force-yes debfoster git gitg nano \
  cron openssh-server regexxer software-properties-common ruby ruby-dev git-core screen \
  sudo thunar \

# Codex tools
  git ripgrep sed grep coreutils findutils diffutils \
  gh glab jq curl ca-certificates gnupg \
  less file procps iproute2 \
  tar gzip bzip2 xz-utils unzip zip bubblewrap \
  build-essential make pkg-config \
  python3 python3-pip \
  openssh-client rsync tree fd-find bat && \

  apt-get clean && \
  deluser --remove-home ubuntu && \


# Firefox
  add-apt-repository ppa:mozillateam/ppa && \
  apt-get update && apt-get install -y --force-yes firefox && \
  apt-get clean && \

# Dev user
  echo "Configure dev user" && \
  /usr/sbin/useradd -s /bin/bash -m dev && \
  mv /tmp/dev.rvmrc /home/dev/.rvmrc && \
  chown dev:dev -R /home/dev && \
  /bin/bash -lc 'echo '\''export PATH="$HOME/.local/bin:$PATH"'\'' >> /home/dev/.profile' && \
  chown dev:dev /home/dev/.profile && \

# Use auth keys to access SSH in shared/ssh/authorized_keys instead of a password
#   echo "dev:password" | chpasswd && \

  echo "Configure SSH" && \
  mkdir /home/dev/.ssh && \
  chmod 700 /home/dev/.ssh && \
  chown -R dev:dev /home/dev/.ssh && \
  ln -s /shared/ssh/config /home/dev/.ssh/config && \
  ln -s /shared/ssh/authorized_keys /home/dev/.ssh/authorized_keys && \
  mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original && \
  ln -s /shared/ssh/sshd_config /etc/ssh/sshd_config && \

# Heroku CLI doesn't support 24.10 yet
#  echo "Install Heroku CLI" && \
#   curl https://cli-assets.heroku.com/install-ubuntu.sh | sh && \

# This repo doesn't have a 24.10 version yet
#  echo "Install Java" && \
#  apt-get install -y --force-yes software-properties-common && apt-get clean && \
#  add-apt-repository ppa:linuxuprising/java && \
#  /bin/bash -c "echo debconf shared/accepted-oracle-license-v1-3 select true | debconf-set-selections" && \
#  /bin/bash -c "echo debconf shared/accepted-oracle-license-v1-3 seen true | debconf-set-selections" && \
#  apt-get update && apt-get install -y --force-yes oracle-java17-installer && apt-get clean && \

  echo "Install NodeJS" && \
  curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash - && \
  apt-get update && apt-get install -y --force-yes nodejs && \
  node --version | grep -Eq '^v24\.' && \

  echo "Install latest npm" && \
  npm install --global npm && \
  echo "Install Claude Code from Anthropic's signed APT repository" && \
  install -d -m 0755 /etc/apt/keyrings && \
  curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc && \
  test "$(gpg --batch --show-keys --with-colons /etc/apt/keyrings/claude-code.asc | awk -F: '$1 == "fpr" { print $10; exit }')" = "31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE" && \
  echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" > /etc/apt/sources.list.d/claude-code.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends "claude-code=${CLAUDE_CODE_VERSION}-1" && \
  echo "Install Codex CLI via OpenAI's native installer" && \
  curl -fsSL https://chatgpt.com/codex/install.sh -o /tmp/codex-install.sh && \
  env CODEX_RELEASE="${CODEX_VERSION}" CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR=/usr/local/bin CODEX_HOME=/opt/codex sh /tmp/codex-install.sh && \
  echo "Install Kimi Code CLI via Moonshot AI's native installer" && \
  curl -fsSL https://code.kimi.com/kimi-code/install.sh -o /tmp/kimi-install.sh && \
  env KIMI_VERSION="${KIMI_CODE_VERSION}" KIMI_INSTALL_DIR=/usr/local bash /tmp/kimi-install.sh && \
  echo "Install OpenCode via its native installer" && \
  install -d -m 0755 /opt/opencode && \
  curl -fsSL https://opencode.ai/install -o /tmp/opencode-install.sh && \
  env HOME=/opt/opencode PATH="/opt/opencode/.opencode/bin:${PATH}" bash /tmp/opencode-install.sh --version "${OPENCODE_VERSION}" && \
  ln -sf /opt/opencode/.opencode/bin/opencode /usr/local/bin/opencode && \
  echo "Install Qwen Code via its native standalone installer" && \
  curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh -o /tmp/qwen-code-install.sh && \
  env QWEN_INSTALL_ROOT=/opt/qwen-code QWEN_NO_MODIFY_PATH=1 bash /tmp/qwen-code-install.sh --method standalone --version "${QWEN_CODE_VERSION}" --source github && \
  chmod 0755 /usr/local/bin/qwen && \
  test "$(codex --version)" = "codex-cli ${CODEX_VERSION}" && \
  test "$(claude --version)" = "${CLAUDE_CODE_VERSION} (Claude Code)" && \
  test "$(kimi --version)" = "${KIMI_CODE_VERSION}" && \
  test "$(opencode --version)" = "${OPENCODE_VERSION}" && \
  test "$(qwen --version)" = "${QWEN_CODE_VERSION}" && \
  rm -f /tmp/codex-install.sh /tmp/kimi-install.sh /tmp/opencode-install.sh /tmp/qwen-code-install.sh && \
  echo "Verify shared AI CLIs as root and dev" && \
  for cli in codex claude kimi opencode qwen; do resolved="$(command -v "$cli")" && case "$resolved" in /usr/local/bin/*|/usr/bin/*) ;; *) exit 1 ;; esac && "$cli" --version; done && \
  su dev -c 'for cli in codex claude kimi opencode qwen; do resolved="$(command -v "$cli")" && case "$resolved" in /usr/local/bin/*|/usr/bin/*) ;; *) exit 1 ;; esac && "$cli" --version; done' && \
  echo "Install Yarn" && \
  npm install --global yarn && \

# Build deps for the Ruby and various gems
  apt-get update && apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev mariadb-client libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x libcurl4-openssl-dev xvfb firefox-geckodriver && \
  apt-get clean && \

# ActiveStorage preview stuff
  apt-get update && apt-get install -y ffmpeg libpoppler-glib-dev libvips42 poppler-utils && \

# Install RVM
  apt-get install -y --force-yes dirmngr && \
  su dev -c "gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB" && \
  su dev -c "curl -sSL https://get.rvm.io | bash" && \

  echo "Install Chrome" && \
  apt-get install -y --force-yes libxss1 libindicator7 && \
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  /bin/bash -c "dpkg -i google-chrome*.deb; exit 0" && \
  apt-get install -f -y --force-yes && \
  apt-get clean && \
  rm google-chrome-stable_current_amd64.deb && \

  echo "Install ChromeDriver" && \
  apt-get install -y --force-yes fonts-liberation unzip xdg-utils && \
  apt-get clean && \
  CHROME_MAJOR="$(google-chrome --product-version | cut -d. -f1)" && \
  CHROMEDRIVER_VERSION="$(curl -fsSL "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_${CHROME_MAJOR}")" && \
  wget -N "https://storage.googleapis.com/chrome-for-testing-public/${CHROMEDRIVER_VERSION}/linux64/chromedriver-linux64.zip" -P ~/ && \
  unzip ~/chromedriver-linux64.zip -d ~/ && \
  rm ~/chromedriver-linux64.zip && \
  mv -f ~/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
  rm -rf ~/chromedriver-linux64 && \
  chown root:root /usr/local/bin/chromedriver && \
  chmod 0755 /usr/local/bin/chromedriver && \

  echo "Checking dev login shell defaults" && \
  su dev -c 'TERM=xterm-256color /bin/bash -lic '\''test -n "$LS_COLORS" && alias ls | grep -q -- "--color=auto" && grep -Fq "\\033[01;32m" <<< "$PS1"'\''' && \

  echo "Preparing home dir to be moved into mount on first boot" && \
  mv /home/dev /home/dev-sample

# Add the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
