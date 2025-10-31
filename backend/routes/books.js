import express from 'express';
import fs from 'fs';
import path from 'path';
import multer from 'multer';
const router = express.Router();

const dataFile = path.join(process.cwd(), 'backend', 'data', 'books.json');
const filesDir = path.join(process.cwd(), 'backend', 'files');

function ensureData() {
  if (!fs.existsSync(path.dirname(dataFile))) fs.mkdirSync(path.dirname(dataFile), { recursive: true });
  if (!fs.existsSync(filesDir)) fs.mkdirSync(filesDir, { recursive: true });
  if (!fs.existsSync(dataFile)) {
    const starter = [
      { id: "1", title: "Sample Book", filePath: "sample_book.epub", lastReadChapter: 0 }
    ];
    fs.writeFileSync(dataFile, JSON.stringify(starter, null, 2));
    const samplePath = path.join(filesDir, 'sample_book.epub');
    if (!fs.existsSync(samplePath)) fs.writeFileSync(samplePath, '');
  }
}

function loadBooks() {
  ensureData();
  const raw = fs.readFileSync(dataFile, 'utf-8');
  return JSON.parse(raw);
}

function saveBooks(arr) {
  fs.writeFileSync(dataFile, JSON.stringify(arr, null, 2));
}

router.get('/books', (req, res) => {
  const books = loadBooks();
  res.json(books);
});

router.post('/progress', (req, res) => {
  const { id, chapter } = req.body;
  if (!id) return res.status(400).json({ message: 'Missing id' });
  const books = loadBooks();
  const book = books.find(b => b.id.toString() === id.toString());
  if (!book) return res.status(404).json({ message: 'Book not found' });
  book.lastReadChapter = Number(chapter) || 0;
  saveBooks(books);
  res.json({ message: 'Saved', book });
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, filesDir),
  filename: (req, file, cb) => cb(null, file.originalname)
});
const upload = multer({ storage });

router.post('/upload', upload.single('epub'), (req, res) => {
  ensureData();
  const books = loadBooks();
  const file = req.file;
  if (!file) return res.status(400).json({ message: 'No file' });
  const id = String(Date.now());
  const newBook = { id, title: req.body.title || file.originalname, filePath: file.filename, lastReadChapter: 0 };
  books.push(newBook);
  saveBooks(books);
  res.status(201).json(newBook);
});

export default router;
