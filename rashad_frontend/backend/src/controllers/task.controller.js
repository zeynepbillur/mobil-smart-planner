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

  static async getAllTasks(req, res) {
    try {
      const tasks = await TaskService.getAllAdmin();
      return new Response(tasks).success(res);
    } catch (error) {
      return new Response(null, error.message).error500(res);
    }
  }

  static async getUserTasks(req, res) {
    try {
      const { userId } = req.params;
      console.log(`[DEBUG] TaskController.getUserTasks - Received userId: ${userId}`);
      const tasks = await TaskService.getAll(userId);
      console.log(`[DEBUG] TaskController.getUserTasks - Found ${tasks.length} tasks for user ${userId}`);
      return new Response(tasks).success(res);
    } catch (error) {
      console.error(`[DEBUG] TaskController.getUserTasks ERROR:`, error);
      return new Response(null, error.message).error500(res);
    }
  }

  static async createTask(req, res) {
    try {
      console.log('Creating task:', req.body);
      console.log('User ID:', req.user._id);

      const task = await TaskService.create({
        ...req.body,
        userId: req.user._id,
      });

      console.log('Task created:', task);
      return new Response(task, "Görev oluşturuldu").created(res);
    } catch (error) {
      console.error('Task creation error:', error);
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
