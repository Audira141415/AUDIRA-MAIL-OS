import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/industrial_theme.dart';
import '../../../../core/components/industrial_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AiCopilotTab extends StatefulWidget {
  const AiCopilotTab({super.key});

  @override
  State<AiCopilotTab> createState() => _AiCopilotTabState();
}

class _AiCopilotTabState extends State<AiCopilotTab> {
  final List<Map<String, String>> _messages = [
    { 'role': 'assistant', 'content': 'SYSTEM ONLINE. I am the Audira AI Copilot. How can I assist you today?' }
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({ 'role': 'user', 'content': text });
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      // Hardcoded for emulator, should use ApiClient ideally
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3311/api/copilot/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({ 'message': text }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({ 'role': 'assistant', 'content': data['content'] ?? 'No response' });
        });
      } else {
        setState(() {
          _messages.add({ 'role': 'assistant', 'content': 'ERROR: Server returned ${response.statusCode}' });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({ 'role': 'assistant', 'content': 'ERROR: Connection failed.' });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI TERMINAL',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                )
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IndustrialCard(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUser ? '> USER_INPUT' : 'SYSTEM RESPONSE:',
                            style: TextStyle(
                              color: isUser ? AppColors.accent : AppColors.textMuted,
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            msg['content'] ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, boxShadow: IndustrialTheme.glowShadow(AppColors.accent)),
                ),
                const SizedBox(width: 8),
                const Text('PROCESSING...', style: TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.chassis,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: AppColors.shadowDark, offset: Offset(4, 4), blurRadius: 8),
                BoxShadow(color: AppColors.shadowHighlight, offset: Offset(-4, -4), blurRadius: 8),
              ]
            ),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: 'AWAITING_INPUT...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.terminal, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.accent),
                  onPressed: _handleSend,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
