FROM ubuntu:16.04

# APT configuration
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --force-yes apt-utils

# Install base packages
RUN apt-get install -y --force-yes debfoster elasticsearch nano cron openssh-server redis-server sudo thunar

# Configure dev user
RUN /usr/sbin/useradd -s /bin/bash -m dev
RUN echo "dev:password" | chpasswd

RUN mkdir /home/dev/.ssh
RUN chmod 700 /home/dev/.ssh
RUN chown -R dev:dev /home/dev/.ssh
RUN ln -s /shared/ssh/config /home/dev/.ssh/config
RUN ln -s /shared/ssh/authorized_keys /home/dev/.ssh/authorized_keys

RUN mkdir /var/run/sshd

# Set up allowed sudo commands
COPY ln -s dev_sudo_access /etc/sudoers.d/90-dev-user

# Install MySQL
RUN apt-get -y --force-yes install mysql-server
RUN service mysql start && su -c "mysql -u root -e \"CREATE USER 'dev'@'%'\"" && su -c "mysql -u root -e \"GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%' WITH GRANT OPTION;\"" && service mysql stop
RUN rm /etc/mysql/mysql.conf.d/mysqld.cnf
RUN ln -s /shared/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# Install Postgres
RUN apt-get -y --force-yes install postgresql postgresql-contrib libpq-dev
RUN service postgresql start && su postgres -c "createuser -d -r -s dev" && service postgresql stop
RUN rm /etc/postgresql/9.5/main/pg_hba.conf
RUN rm /etc/postgresql/9.5/main/postgresql.conf
RUN ln -s /shared/postgres/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf
RUN ln -s /shared/postgres/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

# Install Ruby
RUN apt-get install -y --force-yes ruby2.3 ruby2.3-dev git-core
RUN gem install bundler

# Install Git
RUN apt-get install -y --force-yes git gitg

# Build deps for the Ruby and various gems
RUN apt-get install -y --force-yes build-essential automake bison autoconf pkg-config \
  openssl libssl-dev zlib1g zlib1g-dev libyaml-dev git-core curl gawk g++ gcc make \
  libc6-dev libreadline6-dev libgdbm-dev libncurses5-dev libtool libffi-dev \
  libxslt-dev libxml2-dev libmysqlclient-dev libmagick++-dev imagemagick \
  libsqlite3-dev sqlite3 libpq-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base \
  gstreamer1.0-tools gstreamer1.0-x libcurl4-openssl-dev xvfb

# Install NodeJS
RUN apt-get install -y --force-yes nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install RVM
RUN su dev -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
RUN su dev -c "curl -sSL https://get.rvm.io | bash"

# Add the entrypoint
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
