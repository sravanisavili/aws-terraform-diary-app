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
  let entriesHtml = diaryEntries
    .map(entry => `<li>\${entry}</li>`)
    .join("");

  res.send(`
    <html>
      <head>
        <title>Personal Diary</title>
      </head>
      <body style="font-family: Arial; padding: 20px;">
        <h1>📖 My Personal Diary</h1>

        <form method="POST" action="/add">
          <textarea name="entry" rows="4" cols="50" placeholder="Write your thoughts..." required></textarea><br><br>
          <button type="submit">Add Entry</button>
        </form>

        <h2>Entries:</h2>
        <ul>
          \${entriesHtml}
        </ul>
      </body>
    </html>
  `);
});

app.post("/add", (req, res) => {
  const entry = req.body.entry;
  diaryEntries.push(entry);
  res.redirect("/");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Diary app running on port \${PORT}`);
});
EOF

# Run app in background
nohup node app.js > app.log 2>&1 &