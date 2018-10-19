FROM ubuntu:18.04

# Locale configuration
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# APT configuration
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --force-yes apt-utils wget curl

# Locale install
RUN apt-get update && apt-get install -y --force-yes locales
RUN locale-gen "en_US.UTF-8"

# Install base apps and packages
RUN apt-get update && apt-get install -y --force-yes debfoster git gitg nano \
  cron openssh-server redis-server regexxer ruby ruby-dev git-core screen \
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

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Java
RUN apt-get install -y --force-yes software-properties-common
RUN add-apt-repository ppa:linuxuprising/java
RUN ["/bin/bash", "-c", "echo debconf shared/accepted-oracle-license-v1-2 select true | debconf-set-selections"]
RUN ["/bin/bash", "-c", "echo debconf shared/accepted-oracle-license-v1-2 seen true | debconf-set-selections"]
RUN apt-get update && apt-get install -y --force-yes oracle-java11-installer

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
RUN apt-get update && apt-get install -y --force-yes nodejs

# Yarn
RUN apt-get remove --purge cmdtest
RUN ["/bin/bash", "-c", "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"]
RUN ["/bin/bash", "-c", "echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | tee /etc/apt/sources.list.d/yarn.list"]
RUN apt-get update && apt-get install -y --force-yes yarn

# Build deps for the Ruby and various gems
RUN apt-get update && apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x libcurl4-openssl-dev xvfb

# Install RVM
RUN apt-get install -y --force-yes dirmngr
RUN su dev -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
RUN su dev -c "curl -sSL https://get.rvm.io | bash"

# Rubies with RVM SSL libs
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm autolibs enable"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm pkg install openssl"
# RUN apt-get remove --purge -y libssl-dev && apt-get autoremove -y

# Rubies with normal SSL libs
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm autolibs disable"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.1"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.2"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 1.9.3"

# Rubies
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.3"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.4"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.5"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.6"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.7"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.2.8"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.1"

# Test that SSL is working
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm use 2.3.1 && gem install specific_install && gem specific_install https://github.com/kaspernj/stripe_model_callbacks.git"

# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.2"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.3"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.4"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.5"
# RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.3.6"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.0"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.1"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.2"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.3"
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm install 2.4.4"

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
RUN chown root:root /usr/local/bin/chromedriver
RUN chmod 0755 /usr/local/bin/chromedriver

# Clean up
RUN apt-get clean
RUN su dev -c "source /home/dev/.rvm/scripts/rvm && rvm cleanup all"

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
