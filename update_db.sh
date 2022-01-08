#!/bin/bash

set -e
mongodump -d SimpleProject --out ~/local_dump/`date +"%m-%d-%y"`
mongorestore --uri mongodb+srv://ProjectUser:geqPPSUzKLWDeTxC@cluster0.noog9.mongodb.net/SimpleProject ~/local_dump/`date +"%m-%d-%y"`/SimpleProject