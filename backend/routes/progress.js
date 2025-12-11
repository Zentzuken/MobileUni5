import express from "express";
import fs from "fs-extra";

const router = express.Router();
const DATA_FILE = "./backend/data/books.json";

router.post("/", async (req, res) => {
  const { id, chapter } = req.body;

  if (!id || chapter === undefined) {
    return res.status(400).json({ message: "Missing book ID or chapter" });
  }

  try {
    const books = await fs.readJson(DATA_FILE);
    const bookIndex = books.findIndex((b) => b.id === id);

    if (bookIndex === -1) {
      return res.status(404).json({ message: "Book not found" });
    }

    books[bookIndex].lastReadChapter = chapter;
    await fs.writeJson(DATA_FILE, books, { spaces: 2 });

    res.json({ message: "Progress updated successfully" });
  } catch (err) {
    console.error("Error updating progress:", err);
    res.status(500).json({ message: "Failed to update progress" });
  }
});

export default router;
