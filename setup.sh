#!/bin/bash

# Update system
apt update -y

# Install Node.js and npm
apt install -y nodejs npm

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Initialize project
npm init -y

# Install Express
npm install express

# Create app.js
cat <<EOF > app.js
const express = require("express");
const app = express();

const PORT = 3000;

app.use(express.urlencoded({ extended: true }));

let diaryEntries = [];

app.get("/", (req, res) => {
  let entriesHtml = diaryEntries.map(e => \`<li>\${e}</li>\`).join("");

  res.send(\`
    <html>
      <body>
        <h1>Diary</h1>
        <form method="POST" action="/add">
          <textarea name="entry"></textarea>
          <button type="submit">Add</button>
        </form>
        <ul>\${entriesHtml}</ul>
      </body>
    </html>
  \`);
});

app.post("/add", (req, res) => {
  diaryEntries.push(req.body.entry);
  res.redirect("/");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log("Running on port " + PORT);
});
EOF

# Run app
nohup node app.js > app.log 2>&1 &