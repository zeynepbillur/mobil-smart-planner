const AIService = require("../services/ai.service");
const TaskService = require("../services/task.service");
const Response = require("../utils/response");

class AIController {
  static async chat(req, res) {
    try {
      const userId = req.user._id;
      const tasks = await TaskService.getAll(userId);

      const prompt = req.body.prompt || "Bugün hangi görevler öncelikli?";
      const aiResponse = await AIService.analyzeTasks(tasks, prompt);

      return new Response({ message: aiResponse }).success(res);
    } catch (err) {
      return new Response(null, err.message).error500(res);
    }
  }
}

module.exports = AIController;
