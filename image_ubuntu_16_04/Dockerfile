FROM ubuntu:16.04

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ADD postgres-utf8-fix.sql /tmp/postgres-utf8-fix.sql

RUN chmod +x /usr/local/bin/entrypoint.sh && \
  apt-get update && apt-get install -y --force-yes apt-utils wget curl && \

# Locale install
  apt-get update && apt-get install -y --force-yes locales && \
  locale-gen "en_US.UTF-8" && \

# Install base apps and packages
  apt-get update && apt-get install -y --force-yes debfoster firefox-geckodriver git gitg nano \
  cron openssh-server redis-server regexxer ruby2.3 ruby2.3-dev git-core screen \
  sudo thunar && \

  echo "Configure dev user" && \
  /usr/sbin/useradd -s /bin/bash -m dev && \

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
  mkdir /var/run/sshd && \

  echo "Install MySQL" && \
  apt-get -y --force-yes install mysql-server && \
  service mysql start && su -c "mysql -u root -e \"CREATE USER 'dev'@'%'\"" && \
  su -c "mysql -u root -e \"GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%' WITH GRANT OPTION;\"" && service mysql stop && \
  rm /etc/mysql/mysql.conf.d/mysqld.cnf && \
  ln -s /shared/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf && \

  echo "Install PostgreSQL" && \
  apt-get -y --force-yes install postgresql postgresql-contrib libpq-dev && \
  service postgresql start && su postgres -c "createuser -d -r -s dev" && service postgresql stop && \
  service postgresql restart && sudo -u postgres psql -f /tmp/postgres-utf8-fix.sql && service postgresql stop && \

  echo "Install Heroku CLI" && \
  curl https://cli-assets.heroku.com/install-ubuntu.sh | sh && \

  echo "Install Java" && \
  apt-get install -y --force-yes software-properties-common && \
  add-apt-repository ppa:linuxuprising/java && \
  /bin/bash -c "echo debconf shared/accepted-oracle-license-v1-2 select true | debconf-set-selections" && \
  /bin/bash -c "echo debconf shared/accepted-oracle-license-v1-2 seen true | debconf-set-selections" && \
  apt-get update && apt-get install -y --force-yes oracle-java16-installer && \

  echo "Install Elasticsearch" && \
  /bin/bash -c "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -" && \
  /bin/bash -c "echo \"deb https://artifacts.elastic.co/packages/6.x/apt stable main\" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list" && \
  apt-get update && apt-get install -y --force-yes elasticsearch && \

  echo "Install NodeJS" && \
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - && \
  apt-get update && apt-get install -y --force-yes nodejs && \

  echo "Install Yarn" && \
  apt-get remove --purge cmdtest && \
  /bin/bash -c "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -" && \
  /bin/bash -c "echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | tee /etc/apt/sources.list.d/yarn.list" && \
  apt-get update && apt-get install -y --force-yes yarn && \
  apt-get clean && \

# Build deps for the Ruby and various gems
  apt-get update && apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \ && \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x libcurl4-openssl-dev xvfb && \

# Install RVM
  apt-get install -y --force-yes dirmngr && \
  su dev -c "gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB" && \
  su dev -c "curl -sSL https://get.rvm.io | bash" && \

# Rubies with RVM SSL libs
#   su dev -c "source /home/dev/.rvm/scripts/rvm && rvm autolibs enable" && \
#   su dev -c "source /home/dev/.rvm/scripts/rvm && rvm pkg install openssl" && \

  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm autolibs disable" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.1" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.2" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.3" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.3" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.4" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.5" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.6" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.7" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.8" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.1" && \

# Test that SSL is working
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm use 2.3.1 && gem install specific_install && gem specific_install https://github.com/kaspernj/stripe_model_callbacks.git" && \

  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.2" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.3" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.4" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.5" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.6" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.0" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.1" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.2" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.3" && \
  su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.4" && \

  su build -c "source /home/build/.rvm/scripts/rvm && rvm cleanup all" && \

  echo "Install Chrome" && \
  apt-get install -y --force-yes libxss1 libappindicator1 libindicator7 && \
  apt-get clean && \
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome*.deb; exit 0
RUN apt-get install -f -y --force-yes && \

  echo "Install ChromeDriver" && \
  apt-get install -y --force-yes unzip && \
  apt-get clean && \
  wget -N http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip -P ~/ && \
  unzip ~/chromedriver_linux64.zip -d ~/ && \
  rm ~/chromedriver_linux64.zip && \
  sudo mv -f ~/chromedriver /usr/local/bin/chromedriver && \
  chown root:root /usr/local/bin/chromedriver && \
  chmod 0755 /usr/local/bin/chromedriver && \

  echo "Preparing home dir to be moved into mount on first boot" && \
  mv /home/dev /home/dev-sample

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
