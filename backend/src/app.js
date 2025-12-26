const express = require("express");
const cors = require("cors");
const routes = require("./routes/routes");

const app = express();

app.use(cors());
app.use(express.json());

app.post("/api/test", (req, res) => {
  console.log("oldu sorun başka yerde", req.body);
  res.status(200).json({ ok: true, body: req.body });
});

app.use("/api", routes);


app.get("/", (req, res) => {
  res.send("API is running");
});

module.exports = app;
