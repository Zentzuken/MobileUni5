const express = require("express");
const router = express.Router();
const path = require("path");
const fs = require("fs");

const UPLOAD_DIR = path.join(__dirname, "../uploads");

router.get("/", (req, res) => {
  const files = fs.readdirSync(UPLOAD_DIR);

  const books = files
    .filter(f => f.endsWith(".epub"))
    .map(file => ({
      id: path.basename(file, ".epub"),
      title: path.basename(file, ".epub"),
      epubUrl: `${req.protocol}://${req.get("host")}/uploads/${file}`,
      coverUrl: `${req.protocol}://${req.get("host")}/uploads/${path.basename(file, ".epub")}.jpg`
    }));

  res.json(books);
});

module.exports = router;
