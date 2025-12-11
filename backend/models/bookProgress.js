const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, '../data/progress.json');

function readDB() {
  if (!fs.existsSync(DB_PATH)) return {};
  const raw = fs.readFileSync(DB_PATH);
  return JSON.parse(raw);
}

function writeDB(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

module.exports = {
  getProgress(userId, bookId) {
    const db = readDB();
    return db[`${userId}_${bookId}`] || null;
  },

  saveProgress(userId, bookId, progress) {
    const db = readDB();
    db[`${userId}_${bookId}`] = progress;
    writeDB(db);
    return progress;
  }
};
