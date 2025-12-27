import 'package:rashad_frontend/utils/api_client.dart';

class AIService {
  final ApiClient _apiClient = ApiClient();

  /// Sends a prompt to the AI chat endpoint.
  /// If [prompt] is null, the backend uses default logic based on user tasks.
  Future<String> chat(String? prompt) async {
    try {
      final response = await _apiClient.post('ai/chat', data: {
        if (prompt != null) 'prompt': prompt,
      });

      if (response.statusCode == 200) {
        return response.data['data']['message'] ?? '';
      } else {
        throw Exception(response.data['message'] ?? 'AI response error');
      }
    } catch (e) {
      rethrow;
    }
  }
}
