const AIService = require("../services/ai.service");
const TaskService = require("../services/task.service");
const Response = require("../utils/response");

class AIController {
  static async chat(req, res) {
    try {
      console.log("AIController.chat çağrıldı."); // 🔹 log
      const userId = req.user._id;
      console.log("Kullanıcı ID:", userId); // 🔹 log

      const tasks = await TaskService.getAll(userId);
      console.log("TaskService.getAll sonucu:", tasks); // 🔹 log

      const prompt = req.body.prompt || (tasks.length === 0
        ? "Henüz görevim yok, bana genel tavsiyelerde bulun."
        : "Bugün hangi görevler öncelikli?");

      const aiResponse = await AIService.analyzeTasks(tasks, prompt);

      console.log("AI cevabı:", aiResponse); // 🔹 log
      return new Response({ message: aiResponse }).success(res);
    } catch (err) {
      console.error("Controller AI hatası:", err); // 🔹 detaylı log
      return new Response(null, err.message).error500(res);
    }
  }
}

module.exports = AIController;
