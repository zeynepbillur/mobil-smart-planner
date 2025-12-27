const mongoose = require("mongoose");
require("dotenv/config");

const ProgramModel = require("./src/data/models/Program.model");

async function addCodes() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected");

    const programs = await ProgramModel.find({ code: { $exists: false } });
    
    for (const program of programs) {
      const code = Math.random().toString(36).substring(2, 8).toUpperCase();
      program.code = code;
      await program.save();
      console.log(`Added code ${code} to program: ${program.name}`);
    }

    console.log("All codes added successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Error:", err);
    process.exit(1);
  }
}

addCodes();
