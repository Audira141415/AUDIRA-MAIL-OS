import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/inbox_controller.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxState = ref.watch(inboxControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('UNIFIED INBOX', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(inboxControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: inboxState.when(
        data: (emails) {
          if (emails.isEmpty) {
            return const Center(child: Text('NO INBOUND MESSAGES', style: TextStyle(color: Colors.grey, fontFamily: 'monospace')));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(inboxControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: emails.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E293B), height: 1),
              itemBuilder: (context, index) {
                final email = emails[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: const Color(0xFF0F172A),
                  leading: CircleAvatar(
                    backgroundColor: email.isRead ? const Color(0xFF1E293B) : Colors.blueAccent,
                    radius: 6,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          email.sender.toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14), 
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                      Text(
                        "${email.receivedAt.toLocal().hour.toString().padLeft(2, '0')}:${email.receivedAt.toLocal().minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            email.subject, 
                            style: const TextStyle(color: Colors.grey, fontSize: 13), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        if (email.category != 'General')
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF334155))
                            ),
                            child: Text(email.category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                  onTap: () {
                    context.push('/email/${email.id}', extra: email);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
