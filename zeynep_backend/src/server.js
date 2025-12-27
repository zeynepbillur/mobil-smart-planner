//server.js
require("dotenv").config();
const app = require("./app");
const { connectDB } = require("./data");

connectDB();

app.listen(5000, () => {
  console.log("Server running on 5000");
});
 