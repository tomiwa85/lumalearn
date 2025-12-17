import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';
import 'package:lumalearn/features/session/services/chat_service.dart';
import 'package:intl/intl.dart';

// Provider to fetch linked students
final linkedStudentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(chatServiceProvider).getLinkedStudents();
});

class ScoutDashboardScreen extends ConsumerWidget {
  const ScoutDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(linkedStudentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text("Scout Dashboard"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text("No students linked yet.",
                  style: TextStyle(color: AppTheme.textGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['student_id'];
              final userData =
                  student['users'] as Map<String, dynamic>; // Joined data
              final name = userData['full_name'] ?? 'Unknown Student';

              return _StudentCard(studentId: studentId, studentName: name);
            },
          );
        },
      ),
      // General School Guide Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.neonGreen,
        onPressed: () {
          // Open General Chat about School
          context.push('/session', extra: {
            'id': null, // New session
            'subject': 'General',
          });
        },
        icon: const Icon(Icons.info_outline, color: Colors.black),
        label:
            const Text("School Guide", style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

class _StudentCard extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const _StudentCard({required this.studentId, required this.studentName});

  @override
  ConsumerState<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends ConsumerState<_StudentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceGrey,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.neonGreen.withOpacity(0.2),
              child: Icon(Icons.person, color: AppTheme.neonGreen),
            ),
            title: Text(widget.studentName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Student",
                style: TextStyle(color: AppTheme.textGrey)),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(color: Colors.white10),

            // AI Parent Advisor Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open Parent Analysis Chat
                    context.push('/session', extra: {
                      'id': null,
                      'subject': 'Parent',
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  label: Text("Ask AI about ${widget.studentName}"),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Sessions:",
                    style: TextStyle(
                        color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
              ),
            ),

            // Child Session History
            _StudentSessionList(studentId: widget.studentId),

            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _StudentSessionList extends ConsumerWidget {
  final String studentId;

  const _StudentSessionList({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use a FutureProvider here because it's a one-time fetch or pull-to-refresh ideally
    // But for now, let's just fetch directly in FutureBuilder or similar.
    // Actually better to define a provider or use FutureBuilder.

    return FutureBuilder(
      future: ref.read(chatServiceProvider).getStudentSessions(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (snapshot.hasError) {
          return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Error loading history",
                  style: TextStyle(color: Colors.red)));
        }

        final sessions = snapshot.data as List<ChatSession>;
        if (sessions.isEmpty) {
          return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("No recent activity.",
                  style: TextStyle(
                      color: AppTheme.textGrey, fontStyle: FontStyle.italic)));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.take(5).length, // Show max 5
          itemBuilder: (context, index) {
            final session = sessions[index];
            return ListTile(
              title: Text(session.title,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  "${session.subject} • ${DateFormat('MMM d').format(session.createdAt)}",
                  style:
                      const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              trailing:
                  const Icon(Icons.visibility, color: Colors.white54, size: 16),
              onTap: () {
                // Open Session in Read-Only Mode
                context.push('/session', extra: {
                  'id': session.id,
                  'subject': session.subject,
                });
              },
            );
          },
        );
      },
    );
  }
}
