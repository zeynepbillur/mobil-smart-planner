const { TaskModel } = require("../data");

class TaskService {
  static async getAll(userId) {
    return TaskModel.find({ userId }).sort({ dueDate: 1 });
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
