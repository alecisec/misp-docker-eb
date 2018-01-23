# MISP for Docker / ElasticBeanstalk

This implementation is designed to follow, as closely as possible official MISP install guide for Ubuntu 16.04 at  https://github.com/MISP/MISP/blob/2.4/INSTALL/INSTALL.ubuntu1604.txt
Some modifications have been made in order to surface environment variables as well as syncing persistent data to AWS S3 using s3cmd (s3tools.org)
It has been designed to store data on AWS RDS however any MySQL server should work fine.

s3/config.php should be uploaded to S3 storage as the container entrypoint will attempt to grab it upon launch.
failing to correctly configure S3 will result in attachment date not being retained upon restarting services.

* Deployment: 

Build image
 - docker build -t misp:2.4.86 . --tag <AWSaccountID>.dkr.ecr.<region>.amazonaws.com/misp:2.4.86

Push to ECR 
 - docker push <AWSaccountID>.dkr.ecr.<region>.amazonaws.com/misp:2.4.86

Create an account with access to your S3 bucket and apply the policies:

 - S3accountpolicy.json is applied to the account
 - S3bucketpolicy.json is applied to the bucket

Populate the Environment Variables in Dockerrun.aws.json

Create and popular a MySQL Database using script https://github.com/MISP/MISP/blob/2.4/INSTALL/MYSQL.sql

 - Note with some faily minor changes Postgres can be used instead

Populate the config.yml with key name and region for AWS

Create the Elastic Beanstalk environment

 - eb create misp --cfg misp

* Environment Variables: 

      - DB_USER - Username for MySQL
      - DB_PASSWORD - Password for MySQL
      - DB_HOST - Hostname for MySQL
      - DB_PORT - Port for MySQL
      - EMAIL - Email address for 'send as'
      - RELAY_HOST - SMTP Relay for sending (AWS SES or similar)
      - EMAIL_USER - Username for SMTP Auth
      - EMAIL_PASSWORD - Password for SMTP Auth
      - EMAIL_PORT - Port for SMTP
      - SITE_URL - Site MISP will be hosted at (Breaks if not set, 'https://' appended in config.php, if not using SSL modify to 'http://'
      - S3_KEY - S3 API Key
      - S3_SECRET - S3 API Secret
      - ENV - S3 Bucket Name for pulling config in entrypoint.sh
      - LOG_LEVEL - (Optional, defaults to INFO) Set Supervisor log level, set to debug etc.


* Fixes added for various issues: 

 * Postfix DNS issues resolved by copying /etc/resolve.conf to /var/spool/postfix/etc/resolv.conf (done in entrypoint.sh)
 * MISP modules bind changed from localhost to 127.0.0.1 due to docker failing to resolve localhost (done in Dockerfile)


