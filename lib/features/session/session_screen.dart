import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'providers/session_provider.dart';
import 'models/session_message.dart';
import 'widgets/hint_accordion.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text("Learning Session"),
      ),
      body: Column(
        children: [
          // --- MESSAGES LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: sessionState.messages.length,
              itemBuilder: (context, index) {
                final msg = sessionState.messages[index];

                if (msg.type == MessageType.aiTopicBreakdown) {
                  return _TopicCard(content: msg.content);

                } else if (msg.type == MessageType.aiHint) {
                  return HintAccordion(
                    hintNumber: index,
                    title: msg.isLocked ? "Hint Locked" : "Hint",
                    content: msg.content,
                    isLocked: msg.isLocked,
                  );

                } else if (msg.type == MessageType.feedback) {
                  // --- FEEDBACK CARD (Correct/Incorrect) ---
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: msg.isCorrect
                          ? Colors.green.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: msg.isCorrect ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          msg.isCorrect ? Icons.check_circle : Icons.warning_amber,
                          color: msg.isCorrect ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            msg.content,
                            style: const TextStyle(
                                color: Colors.white, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );

                } else {
                  // --- USER MESSAGE ---
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: const Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        msg.content,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // --- LOADING INDICATOR ---
          if (sessionState.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("LumaLearn is thinking...",
                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 12)),
            ),

          // --- INPUT AREA ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceGrey,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your solution...',
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Send Button
                FloatingActionButton(
                  backgroundColor: AppTheme.neonGreen,
                  mini: true,
                  onPressed: () {
                    ref.read(sessionProvider.notifier).submitUserAnswer(controller.text);
                    controller.clear();
                  },
                  child: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget for Topic Card ---
class _TopicCard extends StatelessWidget {
  final String content;
  const _TopicCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOPIC BREAKDOWN",
              style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}