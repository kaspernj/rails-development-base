FROM ubuntu:17.10

# Locale configuration
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# APT configuration
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --force-yes apt-utils

# Locale install
RUN apt-get install -y --force-yes locales
RUN locale-gen "en_US.UTF-8"

# Install base apps and packages
RUN apt-get update; apt-get install -y --force-yes debfoster elasticsearch git gitg nano \
  cron nodejs openssh-server redis-server regexxer ruby2.3 ruby2.3-dev git-core screen \
  sudo thunar

# Configure dev user
RUN /usr/sbin/useradd -s /bin/bash -m dev

# Use auth keys to access SSH in shared/ssh/authorized_keys instead of a password
# RUN echo "dev:password" | chpasswd

# Configure SSH
RUN mkdir /home/dev/.ssh
RUN chmod 700 /home/dev/.ssh
RUN chown -R dev:dev /home/dev/.ssh
RUN ln -s /shared/ssh/config /home/dev/.ssh/config
RUN ln -s /shared/ssh/authorized_keys /home/dev/.ssh/authorized_keys
RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original
RUN ln -s /shared/ssh/sshd_config /etc/ssh/sshd_config
RUN mkdir /var/run/sshd

# Install MySQL
RUN apt-get -y --force-yes install mysql-server
RUN service mysql start && su -c "mysql -u root -e \"CREATE USER 'dev'@'%'\"" && su -c "mysql -u root -e \"GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%' WITH GRANT OPTION;\"" && service mysql stop
RUN rm /etc/mysql/mysql.conf.d/mysqld.cnf
RUN ln -s /shared/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# Install Postgres
RUN apt-get -y --force-yes install postgresql postgresql-contrib libpq-dev
RUN service postgresql start && su postgres -c "createuser -d -r -s dev" && service postgresql stop
ADD postgres-utf8-fix.sql /tmp/postgres-utf8-fix.sql
RUN service postgresql restart && sudo -u postgres psql -f /tmp/postgres-utf8-fix.sql && service postgresql stop

# Install Heroku CLI
RUN wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Install Yarn
RUN apt-get update && apt-get install -y --force-yes curl wget
RUN apt-get remove --purge cmdtest
RUN ["/bin/bash", "-c", "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"]
RUN ["/bin/bash", "-c", "echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | tee /etc/apt/sources.list.d/yarn.list"]
RUN apt-get update
RUN apt-get -o Dpkg::Options::="--force-overwrite" install -y --force-yes yarn

# Chrome
RUN apt-get install -y --force-yes libxss1 libappindicator1 libindicator7
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome*.deb; exit 0
RUN apt-get install -f -y --force-yes

# ChromeDriver
RUN apt-get install -y --force-yes unzip
RUN wget -N http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip -P ~/
RUN unzip ~/chromedriver_linux64.zip -d ~/
RUN rm ~/chromedriver_linux64.zip
RUN sudo mv -f ~/chromedriver /usr/local/bin/chromedriver
RUN sudo chown root:root /usr/local/bin/chromedriver
RUN sudo chmod 0755 /usr/local/bin/chromedriver

# Java
RUN apt-get install -y --force-yes software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN ["/bin/bash", "-c", "echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections"]
RUN ["/bin/bash", "-c", "echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections"]
RUN apt-get install -y --force-yes oracle-java9-installer

# Elasticsearch
RUN ["/bin/bash", "-c", "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -"]
RUN apt-get install -y --force-yes apt-transport-https
RUN ["/bin/bash", "-c", "echo \"deb https://artifacts.elastic.co/packages/6.x/apt stable main\" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list"]
RUN apt-get update
RUN apt-get install -y --force-yes elasticsearch

# Build deps for the Ruby and various gems
RUN apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x libcurl4-openssl-dev xvfb

# Install RVM
RUN apt-get install -y --force-yes dirmngr
RUN su dev -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
RUN su dev -c "curl -sSL https://get.rvm.io | bash"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm autolibs enable"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.1"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.2"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.3"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.3 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.4 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.5 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.6 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.7 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.8 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.1 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.2 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.3 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.4 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.5 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.0 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.1 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.2 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.3 --rubygems ignore"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.4 --rubygems ignore"

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
