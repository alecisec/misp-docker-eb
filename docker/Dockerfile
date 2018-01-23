FROM ubuntu:16.04
MAINTAINER https://github.com/alecisec

# Attempt to model as closely as possible on https://github.com/MISP/MISP/blob/2.4/INSTALL/INSTALL.ubuntu1604.txt
# All DB elements have been stripped as we will be using AWS RDS

# 1. Minimal Ubuntu install

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get -y install postfix

# 2. Install LAMP & dependencies

# Install the dependencies: (some might already be installed)
RUN apt-get -y install curl gcc git gnupg-agent make python python3 openssl redis-server sudo vim zip

# Install Apache2
RUN apt-get -y install apache2 apache2-doc apache2-utils

# Install logging and supervisor
RUN apt-get install -y cron logrotate supervisor rsyslog

# Enable modules, settings, and default of SSL in Apache
RUN a2dismod status
RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2dissite 000-default
RUN a2ensite default-ssl

# Install PHP and dependencies
RUN apt-get -y install libapache2-mod-php php php-cli php-crypt-gpg php-dev php-json php-mysql php-opcache php-readline php-redis php-xml

# 3. MISP code

# Download MISP using git in the /var/www/ directory.
RUN mkdir /var/www/MISP
RUN chown www-data:www-data /var/www/MISP

WORKDIR /var/www/MISP
USER www-data
RUN git clone https://github.com/MISP/MISP.git /var/www/MISP
RUN git checkout tags/$(git describe --tags `git rev-list --tags --max-count=1`)
# if the last shortcut doesn't work, specify the latest version manually
# example: git checkout tags/v2.4.XY

# Make git ignore filesystem permission differences
RUN git config core.filemode false

# install Mitre's STIX and its dependencies by running the following commands:
USER root
RUN apt-get -y install python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev python-setuptools
WORKDIR /var/www/MISP/app/files/scripts
RUN git clone https://github.com/CybOXProject/python-cybox.git
RUN git clone https://github.com/STIXProject/python-stix.git
WORKDIR /var/www/MISP/app/files/scripts/python-cybox
RUN git checkout v2.1.0.12
USER root
RUN python setup.py install
WORKDIR /var/www/MISP/app/files/scripts/python-stix
RUN git checkout v1.1.1.4
RUN python setup.py install

# install mixbox to accomodate the new STIX dependencies:
WORKDIR /var/www/MISP/app/files/scripts/
USER www-data
RUN git clone https://github.com/CybOXProject/mixbox.git
WORKDIR /var/www/MISP/app/files/scripts/mixbox
RUN git checkout v1.0.2
USER root
RUN python setup.py install

# install support for STIX 2.0 (Python 3 is required)
USER root
RUN pip install stix2

# 4. CakePHP

# CakePHP is included as a submodule of MISP, execute the following commands to let git fetch it:
WORKDIR /var/www/MISP
USER www-data
RUN git submodule init
RUN git submodule update

# Once done, install CakeResque along with its dependencies if you intend to use the built in background jobs:
WORKDIR /var/www/MISP/app
USER www-data
RUN php composer.phar require kamisama/cake-resque:4.1.2
RUN php composer.phar config vendor-dir Vendor
RUN php composer.phar install

# Enable CakeResque with php-redis
USER root
RUN phpenmod redis

# To use the scheduler worker for scheduled tasks, do the following:
USER www-data
RUN cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php

# 5. Set the permissions

# Check if the permissions are set correctly using the following commands:
USER root
RUN chown -R www-data:www-data /var/www/MISP
RUN chmod -R 750 /var/www/MISP
RUN chmod -R g+ws /var/www/MISP/app/tmp
RUN chmod -R g+ws /var/www/MISP/app/files
RUN chmod -R g+ws /var/www/MISP/app/files/scripts/tmp

# 7. Apache configuration
RUN cp /var/www/MISP/INSTALL/apache.misp.ubuntu /etc/apache2/sites-enabled/misp.conf

# 9. MISP configuration

# There are 4 sample configuration files in /var/www/MISP/app/Config that need to be copied
USER www-data
RUN cp -a /var/www/MISP/app/Config/bootstrap.default.php /var/www/MISP/app/Config/bootstrap.php
RUN cp -a /var/www/MISP/app/Config/database.default.php /var/www/MISP/app/Config/database.php
RUN cp -a /var/www/MISP/app/Config/core.default.php /var/www/MISP/app/Config/core.php
RUN cp -a /var/www/MISP/app/Config/config.default.php /var/www/MISP/app/Config/config.php

# and make sure the file permissions are still OK
USER root
RUN chown -R www-data:www-data /var/www/MISP/app/Config
RUN chmod -R 750 /var/www/MISP/app/Config

# To make the background workers start on boot
RUN chmod +x /var/www/MISP/app/Console/worker/start.sh
RUN echo 'sudo -u www-data bash /var/www/MISP/app/Console/worker/start.sh' >> /etc/rc.local

# recheck all permission
RUN chmod -R 750 /var/www/MISP/
RUN chown -R www-data:www-data /var/www/MISP/

# add MISP modules
#RUN apt-get -y install python3-dev python3-pip libpq5 libjpeg-dev
#WORKDIR /usr/local/src/
#RUN git clone https://github.com/MISP/misp-modules.git
#WORKDIR /usr/local/src/misp-modules
#RUN pip install --upgrade pip
#RUN pip install -I -r REQUIREMENTS
#RUN pip install -I .

#RUN echo 'sudo -u www-data misp-modules -s & ' >>/etc/rc.local 

# Install MISP Modules
WORKDIR /opt
RUN apt-get install -y python3 python3-pip libjpeg-dev
RUN git clone https://github.com/MISP/misp-modules.git
WORKDIR /opt/misp-modules
RUN pip3 install --upgrade --ignore-installed urllib3
RUN pip3 install --upgrade --ignore-installed requests
RUN pip3 install -I -r REQUIREMENTS
RUN pip3 install -I .
RUN echo "sudo -u www-data misp-modules -s &" >>/etc/rc.local

# Supervisord Setup
RUN echo '[supervisord]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'nodaemon = true' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'loglevel = LOG_LEVEL' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:postfix]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'process_name = master' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'directory = /etc/postfix' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command = /usr/sbin/postfix -c /etc/postfix start' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'startsecs = 0' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'autorestart = false' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:redis-server]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=redis-server /etc/redis/redis.conf' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:apache2]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -D FOREGROUND"' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:resque]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/bin/bash /var/www/MISP/app/Console/worker/start.sh' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'user = www-data' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'startsecs = 0' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'autorestart = false' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:misp-modules]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/bin/bash -c "/usr/local/bin/misp-modules"' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'user = root' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'startsecs = 0' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'autorestart = false' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:rsyslogd]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command = /usr/sbin/rsyslogd -n' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo '[program:s3sync]' >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/bin/bash -c "/s3sync.sh"' >> /etc/supervisor/conf.d/supervisord.conf

# FIX - Change localhost to hostname to prevent misp modules failing to bind port
RUN sed -i "s/localhost/127.0.0.1/" /usr/local/lib/python3.5/dist-packages/misp_modules/__init__.py
RUN sed -i "s/localhost/127.0.0.1/" /usr/local/lib/python3.5/dist-packages/misp_modules/__init__.py

# Add AWSCLI for grabbing conf from s3
RUN apt-get install -y awscli

# Postfix config
RUN rm /etc/postfix/main.cf
RUN echo 'relayhost = ['RELAY_HOST']:587' >> /etc/postfix/main.cf
RUN echo 'smtp_sasl_auth_enable = yes' >> /etc/postfix/main.cf
RUN echo 'smtp_sasl_security_options = noanonymous' >> /etc/postfix/main.cf
RUN echo 'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd' >> /etc/postfix/main.cf
RUN echo 'smtp_use_tls = yes' >> /etc/postfix/main.cf
RUN echo 'smtp_tls_security_level = encrypt' >> /etc/postfix/main.cf
RUN echo 'smtp_tls_note_starttls_offer = yes' >> /etc/postfix/main.cf
RUN echo 'inet_protocols=ipv4' >> /etc/postfix/main.cf
RUN echo 'smtp_generic_maps = hash:/etc/postfix/generic' >> /etc/postfix/main.cf

RUN postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt'

RUN echo '[RELAY_HOST]:EMAIL_PORT EMAIL_USER:EMAIL_PASSWORD' >> /etc/postfix/sasl_passwd
RUN echo 'www-data EMAIL' >> /etc/postfix/generic
RUN sed -i 's/^\(daemonize\s*\)yes\s*$/\1no/g' /etc/redis/redis.conf

# setup tools for syncing content to S3

WORKDIR /
RUN apt-get install -y s3cmd

# add docker entrypoint
WORKDIR /

ADD entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
ADD s3sync.sh /s3sync.sh
RUN chmod 0755 /s3sync.sh


EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]

