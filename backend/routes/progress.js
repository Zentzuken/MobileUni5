const express = require('express');
const router = express.Router();
const Progress = require('../models/bookProgress');

router.post("/", (req, res) => {
  const { userId, bookId, lastChapter, lastPosition } = req.body;

  const updated = Progress.saveProgress(userId, bookId, {
    lastChapter,
    lastPosition,
    timestamp: Date.now()
  });

  res.json(updated);
});

router.get("/:userId/:bookId", (req, res) => {
  const { userId, bookId } = req.params;

  const p = Progress.getProgress(userId, bookId);

  res.json(p || {});
});

module.exports = router;
