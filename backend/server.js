const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());

// serve epub files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// routes
app.use("/api/books", require('./routes/books'));
app.use("/api/progress", require('./routes/progress'));

// landing
app.get("/", (req, res) => {
  res.send("Backend Running");
});


app.listen(3000, () => console.log("Backend running on http://localhost:3000"));
