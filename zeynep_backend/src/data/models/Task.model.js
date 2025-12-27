const mongoose = require("mongoose");

const TaskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true
    },
    description: {
      type: String,
      default: ""
    },
    dueDate: {
      type: Date,
      required: true
    },
    status: {
      type: String,
      enum: ["pending", "completed"],
      default: "pending"
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      default: null
    },
    programId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Program",
      required: false,
  }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("Task", TaskSchema);
