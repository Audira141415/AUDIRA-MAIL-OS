import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/email_model.dart';
import '../../data/inbox_repository.dart';

class EmailDetailScreen extends ConsumerStatefulWidget {
  final EmailModel email;

  const EmailDetailScreen({super.key, required this.email});

  @override
  ConsumerState<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends ConsumerState<EmailDetailScreen> {
  String? aiDraft;
  bool isDrafting = false;

  Future<void> _draftReply() async {
    setState(() => isDrafting = true);
    try {
      final repo = ref.read(inboxRepositoryProvider);
      final draft = await repo.draftAiReply(widget.email.subject, widget.email.bodyText);
      setState(() => aiDraft = draft);
    } catch (e) {
      setState(() => aiDraft = '[MOCK MODE] Thank you for your inquiry. We will get back to you shortly.');
    } finally {
      setState(() => isDrafting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('EMAIL DETAILS', style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B1120),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email.subject, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('From: ${widget.email.sender}', style: const TextStyle(color: Colors.grey)),
            Text('Date: ${widget.email.receivedAt.toLocal()}', style: const TextStyle(color: Colors.grey)),
            const Divider(color: Color(0xFF1E293B), height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Text(widget.email.bodyText.isEmpty ? "No plain text body. Please view on web." : widget.email.bodyText, style: const TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF020617), border: Border.all(color: const Color(0xFF1E293B)), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AI_AUTOPILOT_REPLY', style: TextStyle(color: Colors.purpleAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                      if (aiDraft == null)
                        ElevatedButton(
                          onPressed: isDrafting ? null : _draftReply,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          child: Text(isDrafting ? 'DRAFTING...' : 'GENERATE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                    ],
                  ),
                  if (aiDraft != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: aiDraft),
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF0F172A),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => aiDraft = val,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Reply Transmitted!')));
                          setState(() => aiDraft = null);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('TRANSMIT_AI_REPLY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
