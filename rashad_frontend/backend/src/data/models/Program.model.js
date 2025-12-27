const mongoose = require("mongoose");

// 6 haneli rastgele kod üret
function generateCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

const ProgramSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: "" },
  code: { type: String, unique: true, sparse: true },
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  isPublic: { type: Boolean, default: false },
  approvedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  pendingRequests: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
}, { timestamps: true });

// Program oluşturulurken otomatik kod üret
ProgramSchema.pre('save', function (next) {
  if (!this.code) {
    this.code = generateCode();
  }
  if (typeof next === 'function') {
    next();
  }
});

// Model'i sadece bir kez oluştur
module.exports = mongoose.models.Program || mongoose.model("Program", ProgramSchema);
