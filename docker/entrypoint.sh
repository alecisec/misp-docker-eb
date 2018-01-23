#!/bin/bash
#
# MISP docker startup script
#
# 18/1/2018 - First version
#
#

# Environment variables

RELAY_HOST=${RELAY_HOST}
EMAIL=${EMAIL}
EMAIL_USER=${EMAIL_USER}
EMAIL_PASSWORD=${EMAIL_PASSWORD}
EMAIL_PORT=${EMAIL_PORT}
DB_USER=${DB_USER:-none}
DB_PASSWORD=${DB_PASSWORD:-none}
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT_NUMBER:-3306}
SITE_URL=${SITE_URL}
LOG_LEVEL=${LOG_LEVEL:-info}
S3_KEY=${S3_KEY:-KEY}
S3_SECRET=${S3_SECRET:-SECRET}
ENV=${ENV}

# Configure Postfix

sed -i "s/EMAIL/$EMAIL/g" /etc/postfix/generic
postmap hash:/etc/postfix/generic
sed -i "s/RELAY_HOST/$RELAY_HOST/g" /etc/postfix/main.cf 
sed -i "s/RELAY_HOST/$RELAY_HOST/g" /etc/postfix/sasl_passwd
sed -i "s/EMAIL_PORT/$EMAIL_PORT/g" /etc/postfix/sasl_passwd
sed -i "s/EMAIL_USER/$EMAIL_USER/g" /etc/postfix/sasl_passwd
sed -i "s/EMAIL_PASSWORD/$EMAIL_PASSWORD/g" /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd
chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db


# DNS fix for posfix

cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

# Grab latest config from S3

echo 'using configuration file from s3://'$ENV
s3cmd get s3://$ENV/config.php /var/www/MISP/app/Config/config.php --access_key=$S3_KEY --secret_key=$S3_SECRET --force

# Configure SiteURL

sed -i "s|SITE_URL|$SITE_URL|g" /var/www/MISP/app/Config/config.php

# Configure Database

sed -i "s|localhost|$DB_HOST|g" /var/www/MISP/app/Config/database.php
sed -i "s|db login|$DB_USER|g" /var/www/MISP/app/Config/database.php
sed -i "s|db password|$DB_PASSWORD|g" /var/www/MISP/app/Config/database.php
sed -i "s|3306|$DB_PORT|g" /var/www/MISP/app/Config/database.php

# Set loglevel for supervisor (optional)

sed -i "s|LOG_LEVEL|$LOG_LEVEL|g" /etc/supervisor/conf.d/supervisord.conf

# Start Supervisor
echo "Starting supervisord"
cd /
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

