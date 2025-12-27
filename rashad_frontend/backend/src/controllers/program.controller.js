const ProgramService = require("../services/program.service");
const Response = require("../utils/response");

class ProgramController {
  static async createProgram(req, res) {
    try {
      const program = await ProgramService.create({
        ...req.body,
        ownerId: req.user._id,
      });
      return new Response(program, "Program oluşturuldu").created(res);
    } catch (err) {
      return new Response(null, err.message).error400(res);
    }
  }

  static async getPrograms(req, res) {
    try {
      console.log('getPrograms called, user:', req.user?._id);
      const programs = await ProgramService.getAll(req.user._id);
      console.log('Programs found:', programs.length);
      return new Response(programs).success(res);
    } catch (err) {
      console.error('getPrograms error:', err);
      return new Response(null, err.message).error500(res);
    }
  }

  static async approveUser(req, res) {
    try {
      const { programId, userId } = req.body;
      const program = await ProgramService.approveUser(programId, userId);
      return new Response(program, "Kullanıcı onaylandı").success(res);
    } catch (err) {
      return new Response(null, err.message).error400(res);
    }
  }

  static async getProgramTasks(req, res) {
    try {
      const { programId } = req.params;
      const tasks = await ProgramService.getTasks(programId);
      return new Response(tasks).success(res);
    } catch (err) {
      return new Response(null, err.message).error500(res);
    }
  }

  static async updateProgram(req, res) {
    try {
      const { id } = req.params;
      const program = await ProgramService.update(id, req.body, req.user._id);
      return new Response(program, "Program güncellendi").success(res);
    } catch (err) {
      return new Response(null, err.message).error400(res);
    }
  }

  static async deleteProgram(req, res) {
    try {
      const { id } = req.params;
      await ProgramService.delete(id, req.user._id);
      return new Response(null, "Program silindi").success(res);
    } catch (err) {
      return new Response(null, err.message).error400(res);
    }
  }

  static async joinProgram(req, res) {
    try {
      const { code } = req.body;
      const { program, status } = await ProgramService.joinByCode(code, req.user._id);

      const message = status === 'joined'
        ? "Programa başarıyla katıldınız"
        : "Katılım isteğiniz gönderildi, onay bekleniyor";

      return new Response(program, message).success(res);
    } catch (err) {
      return new Response(null, err.message).error400(res);
    }
  }
}

module.exports = ProgramController;
