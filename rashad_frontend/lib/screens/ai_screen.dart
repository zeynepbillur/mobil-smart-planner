import 'package:flutter/material.dart';
import 'package:rashad_frontend/services/ai_service.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_promptController.text.trim().isEmpty) return;

    final userMessage = _promptController.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _promptController.clear();
      _isLoading = true;
    });

    try {
      final aiResponse = await _aiService.chat(userMessage);
      setState(() {
        _messages.add({'role': 'assistant', 'content': aiResponse});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yapay Zeka Asistanı'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'AI ile görevlerini analiz et!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessage(msg['content']!, isUser);
                    },
                  ),
          ),
          if (_isLoading) LinearProgressIndicator(),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryColor.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser 
                ? AppColors.primaryColor.withOpacity(0.3) 
                : AppColors.textHint.withOpacity(0.1)
          ),
        ),
        child: Text(
          content,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.textHint.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'Bir şey sor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: AppColors.primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
