#!/bin/bash
apt update -y
apt install -y nodejs npm
# (app code)
EOF
nohup node app.js > app.log 2>&1 &