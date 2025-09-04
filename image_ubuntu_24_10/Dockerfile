FROM ubuntu:24.10

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ADD apt-preferences-d-firefox /etc/apt/preferences.d/mozilla-firefox

# Auto install Rubies
ADD .rvmrc /home/dev/.rvmrc

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
  sudo thunar && \
  apt-get clean && \
  deluser --remove-home ubuntu && \

# Firefox
  add-apt-repository ppa:mozillateam/ppa && \
  apt-get update && apt-get install -y --force-yes firefox && \
  apt-get clean && \

# Dev user
  echo "Configure dev user" && \
  /usr/sbin/useradd -s /bin/bash -m dev && \
  chown dev:dev -R /home/dev && \

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
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - && \
  apt-get update && apt-get install -y --force-yes nodejs && \

  echo "Install Yarn" && \
  npm install --global yarn && \

# Build deps for the Ruby and various gems
  apt-get update && apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev mariadb-client libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev libqt5webkit5-dev gstreamer1.0-plugins-base \
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
  wget -N http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip -P ~/ && \
  unzip ~/chromedriver_linux64.zip -d ~/ && \
  rm ~/chromedriver_linux64.zip && \
  mv -f ~/chromedriver /usr/local/bin/chromedriver && \
  chown root:root /usr/local/bin/chromedriver && \
  chmod 0755 /usr/local/bin/chromedriver && \

  echo "Preparing home dir to be moved into mount on first boot" && \
  mv /home/dev /home/dev-sample

# Add the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
