const Gemini = require("gemini-ai").default; 
require("dotenv").config();

const gemini = new Gemini(process.env.GEMINI_API_KEY);

class AIService {
  static async analyzeTasks(tasks, prompt = "") {
    try {
      const taskSummary = tasks.map((t) => ({
        title: t.title,
        dueDate: t.dueDate,
        status: t.status,
      }));

      const systemPrompt = `
        Sen bir görev asistanısın.
        Kullanıcıya yapılacak görevleri analiz et ve öneriler ver.
        Görevleri önem sırasına göre yorumla.
      `;

      const userPrompt = `
        ${prompt}
        Görevler:
        ${JSON.stringify(taskSummary, null, 2)}
      `;

      // Tek seferlik chat-like istek
      const response = await gemini.ask(`
System:
${systemPrompt}

User:
${userPrompt}
      `);

      return response || "AI’den cevap alınamadı.";
    } catch (err) {
      console.error("AI analiz hatası:", err.message);
      return "AI analiz sırasında hata oluştu.";
    }
  }
}

module.exports = AIService;
