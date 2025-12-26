const Gemini = require("gemini-ai").default;
require("dotenv").config();

const gemini = new Gemini({ apiKey: process.env.API_KEY });

class AIService {
    
  static async analyzeTasks(tasks, prompt = "") {
    console.log("GEMINI_API_KEY:", process.env.GEMINI_API_KEY);

    try {
      const taskSummary = tasks.map((t) => ({
        title: t.title,
        dueDate: t.dueDate,
        status: t.status,
      }));

      const systemPrompt = `
Sen bir görev asistanısın.
Kullanıcıya yapılacak görevleri analiz et ve önceliklendirilmiş öneriler ver.
`;

      const userPrompt = `
${prompt}
Görevler:
${JSON.stringify(taskSummary, null, 2)}
`;

      // ask() artık object parametre ile çağrılıyor
const response = await gemini.ask({
  model: "gemini-1.5-turbo",
  messages: [
    { role: "system", content: systemPrompt },
    { role: "user", content: userPrompt }
  ],
  max_output_tokens: 300
});

      console.log("Gemini response:", response);
      return response.output_text ?? "AI’den cevap alınamadı."; // SDK output_text döndürüyor
    } catch (err) {
      console.error("AI analiz hatası detay:", err);
      return "AI analiz sırasında hata oluştu.";
    }
  }
}

module.exports = AIService;
