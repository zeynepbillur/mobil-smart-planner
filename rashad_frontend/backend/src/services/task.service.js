const { TaskModel } = require("../data");

class TaskService {
  static async getAll(userId) {
    console.log(`[DEBUG] TaskService.getAll - Searching for tasks with userId: ${userId}`);
    const tasks = await TaskModel.find({ userId }).sort({ dueDate: 1 });
    console.log(`[DEBUG] TaskService.getAll - Found ${tasks.length} tasks`);
    return tasks;
  }

  static async getAllAdmin() {
    return TaskModel.find({}).sort({ createdAt: -1 });
  }

  static async create(payload) {
    return TaskModel.create(payload);
  }

  static async update(id, payload) {
    const task = await TaskModel.findByIdAndUpdate(id, payload, { new: true });
    if (!task) throw new Error("Görev bulunamadı");
    return task;
  }

  static async delete(id) {
    const task = await TaskModel.findByIdAndDelete(id);
    if (!task) throw new Error("Görev bulunamadı");
    return task;
  }
}

module.exports = TaskService;
