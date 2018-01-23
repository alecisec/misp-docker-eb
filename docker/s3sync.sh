#!/bin/bash

#######################################################################################################################
#                                                                                                                     #
# S3 syncing script for MISP.                                                                                         #
# This script runs every few hours and ensures that all userdata for MISP is synced with a selected S3 Bucket         #
# Alec Dixon (alec.dixon@sa.gov.au)                                                                                   #
#                                                                                                                     #
# Updated - 10/1/2017                                                                                                 #
#                                                                                                                     #
#######################################################################################################################

S3_KEY=${S3_KEY:-KEY}
S3_SECRET=${S3_SECRET:-SECRET}
ENV=${ENV}

while true
do

echo "Syncing userdata with S3"
s3cmd sync /var/www/MISP/app/webroot/img s3://$ENV --access_key=$S3_KEY --secret_key=$S3_SECRET
sleep 6h

done

