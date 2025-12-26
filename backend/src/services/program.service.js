const { ProgramModel, TaskModel } = require("../data");

class ProgramService {
  static async create(payload) {
    return ProgramModel.create(payload);
  }

  static async getAll(userId) {
    // Public programlar + onaylı programlar
    return ProgramModel.find({
      $or: [
        { isPublic: true },
        { approvedUsers: userId },
        { ownerId: userId },
      ],
    });
  }

  static async approveUser(programId, userId) {
    const program = await ProgramModel.findById(programId);
    if (!program) throw new Error("Program bulunamadı");

    if (!program.approvedUsers.includes(userId)) {
      program.approvedUsers.push(userId);
      await program.save();
    }
    return program;
  }

  static async getTasks(programId) {
    return TaskModel.find({ programId });
  }
}

module.exports = ProgramService;
