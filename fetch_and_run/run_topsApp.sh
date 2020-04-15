#!/bin/bash

# Command to run locally
#S3_INPUT=s3://dinosar/processing/test/int-20180706-20180624/
#S3_OUTPUT=s3://dinosar/results/uniongap/int-20180706-20180624/
#S3_DEM=s3://dinosar/processing/uniongap/dem

# Mounted EBS volume
echo "Processing disk space available:"
df -h
#lsblk
cd /opt/scratch

echo "Syncing files from ${S3_INTPUT}"
aws s3 sync ${S3_INPUT} .

echo "Syncing dem from ${S3_DEM}"
aws s3 sync ${S3_DEM} .

echo "Downloading SLCs and Orbits..."
aria2c -x 8 -s 8 -i download-links.txt

echo "Running topsApp..."
topsApp.py 2>&1 | tee topsApp.log
# Mock command for testing
#mkdir merged/
#echo "Results!" > merged/results.txt

echo "Syncing results to ${S3_OUTPUT} ..."
cp topsApp.xml topsApp.log topsProc.xml download-links.txt merged/
aws s3 sync merged ${S3_OUTPUT}

# Run for X minutes to allow ssh in for diagnosing scipt errors
sleep 10m

echo "Done!"
