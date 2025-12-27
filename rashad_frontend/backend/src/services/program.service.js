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

    // Onaylananlardan emin olalım, pending'den çekelim
    if (!program.approvedUsers.includes(userId)) {
      program.approvedUsers.push(userId);
      // Pending listesinden çıkaralım
      program.pendingRequests = program.pendingRequests.filter(
        (id) => id.toString() !== userId.toString()
      );
      await program.save();
    }
    return program;
  }

  static async getTasks(programId) {
    return TaskModel.find({ programId });
  }

  static async update(programId, payload, userId) {
    const program = await ProgramModel.findById(programId);
    if (!program) throw new Error("Program bulunamadı");

    // Sadece program sahibi güncelleyebilir
    if (program.ownerId.toString() !== userId.toString()) {
      throw new Error("Bu programı güncelleme yetkiniz yok");
    }

    // Sadece belirli alanları güncelleyebilir
    if (payload.name) program.name = payload.name;
    if (payload.description !== undefined) program.description = payload.description;
    if (payload.isPublic !== undefined) program.isPublic = payload.isPublic;

    await program.save();
    return program;
  }

  static async delete(programId, userId) {
    const program = await ProgramModel.findById(programId);
    if (!program) throw new Error("Program bulunamadı");

    // Sadece program sahibi silebilir
    if (program.ownerId.toString() !== userId.toString()) {
      throw new Error("Bu programı silme yetkiniz yok");
    }

    // Programı sil
    await ProgramModel.findByIdAndDelete(programId);

    // Opsiyonel: Programa bağlı taskları da silebilirsiniz
    // await TaskModel.deleteMany({ programId });
  }

  static async joinByCode(code, userId) {
    console.log(`[DEBUG] joinByCode - Code: ${code}, User: ${userId}`);
    const program = await ProgramModel.findOne({ code });
    if (!program) throw new Error("Program bulunamadı");

    console.log(`[DEBUG] Program found: ${program.name}, isPublic: ${program.isPublic} (type: ${typeof program.isPublic})`);

    // Zaten üye mi kontrol et
    if (program.approvedUsers.some(u => u.toString() === userId.toString())) {
      throw new Error("Bu programa zaten üyesiniz");
    }

    // Zaten isteği var mı kontrol et
    if (program.pendingRequests && program.pendingRequests.some(u => u.toString() === userId.toString())) {
      throw new Error("Zaten katılım isteği gönderdiniz");
    }

    // Owner kendini ekleyemez
    if (program.ownerId && program.ownerId.toString() === userId.toString()) {
      throw new Error("Bu programın sahibisiniz");
    }

    // Programa göre direkt katılım veya istek
    if (program.isPublic === true) {
      console.log("[DEBUG] Joining public program");
      program.approvedUsers.push(userId);
      await program.save();
      return { program, status: 'joined' };
    } else {
      console.log("[DEBUG] Requesting private program");
      if (!program.pendingRequests) program.pendingRequests = [];
      program.pendingRequests.push(userId);
      await program.save();
      return { program, status: 'requested' };
    }
  }
}

module.exports = ProgramService;
