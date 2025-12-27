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
      const programs = await ProgramService.getAll(req.user._id);
      return new Response(programs).success(res);
    } catch (err) {
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
}

module.exports = ProgramController;
