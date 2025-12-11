import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import fs from "fs-extra";

import bookRoutes from "./routes/books.js";
import progressRoutes from "./routes/progress.js";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use("/files", express.static("backend/files")); // serve epub files
app.use("/api/books", bookRoutes);
app.use("/api/progress", progressRoutes);

app.listen(PORT, () => {
  console.log(`✅ Backend running on http://localhost:${PORT}`);
});
