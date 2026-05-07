#!/bin/bash -xe

# Log everything
exec > /var/log/user-data.log 2>&1

apt update -y

# Install Node properly
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Create app
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

npm init -y
npm install express

cat <<EOF > app.js
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Diary App Running 🚀");
});

app.listen(3000, "0.0.0.0", () => {
  console.log("App running");
});
EOF

# Run app
nohup node app.js &