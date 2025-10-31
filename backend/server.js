import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import booksRouter from './routes/books.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());

app.use('/files', express.static(path.join(__dirname, 'files')));
app.use('/api', booksRouter);

app.get('/', (req, res) => res.send('Novel backend running'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
