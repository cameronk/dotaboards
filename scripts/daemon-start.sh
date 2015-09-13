#!/bin/bash

ENV=$1
NOW=$(date +"%m-%d-%Y-%X")

echo "Processing daemon start with env $ENV"

# Store the old monitor data
echo "Moving old monitor file..."
cd ../daemon/storage/monitors
mv -v monitor-latest.json backup/monitor-$NOW.json

echo "Starting dotaboards daemon with process name: dbds"
cd ../daemon/bin
bash -c "exec -a dbds nohup dart dotaboards.dart $ENV > ../storage/out.txt &"

