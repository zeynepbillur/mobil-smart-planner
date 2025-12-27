const TaskService = require("../services/task.service");
const Response = require("../utils/response");

class TaskController {
  static async getTasks(req, res) {
    try {
      const tasks = await TaskService.getAll(req.user._id);
      return new Response(tasks).success(res);
    } catch (error) {
      return new Response(null, error.message).error500(res);
    }
  }

  static async createTask(req, res) {
    try {
      const task = await TaskService.create({
        ...req.body,
        userId: req.user._id,
      });

      return new Response(task, "Görev oluşturuldu").created(res);
    } catch (error) {
      return new Response(null, error.message).error400(res);
    }
  }

  static async updateTask(req, res) {
    try {
      const task = await TaskService.update(req.params.id, req.body);
      return new Response(task, "Görev güncellendi").success(res);
    } catch (error) {
      return new Response(null, error.message).error400(res);
    }
  }

  static async deleteTask(req, res) {
    try {
      await TaskService.delete(req.params.id);
      return new Response(null, "Görev silindi").success(res);
    } catch (error) {
      return new Response(null, error.message).error400(res);
    }
  }
}

module.exports = TaskController;
