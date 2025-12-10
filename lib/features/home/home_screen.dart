import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 1. DATA MODEL FOR SUBJECTS// This mimics the data structure defined in your design document (Section 6) [cite: 51]
  // Later, we will fetch this list from Supabase.
  final List<Map<String, dynamic>> _subjects = const [
    {
      "name": "Physics",
      "progress": 0.75,
      "color": Colors.blueAccent,
      "icon": Icons.bolt,
      "id": "phys_01"
    },
    {
      "name": "Math",
      "progress": 0.60,
      "color": Colors.tealAccent,
      "icon": Icons.calculate,
      "id": "math_01"
    },
    {
      "name": "Chemistry",
      "progress": 0.45,
      "color": Colors.greenAccent,
      "icon": Icons.science,
      "id": "chem_01"
    },
    {
      "name": "Biology",
      "progress": 0.20,
      "color": Colors.pinkAccent,
      "icon": Icons.biotech,
      "id": "bio_01"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      // 2. UPDATED APP BAR WITH LOGO
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // The Logo Image
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/icons/icon_lumalearn.png'),
                  fit: BoxFit.contain,
                ),
                // Subtle glow behind the small logo
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // The App Name
            const Text(
              'LumaLearn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Help / About Icon
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textGrey),
            onPressed: () {
              // Show about dialog or help
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. MAIN SEARCH BAR ("Ask LumaLearn")
            // As described in UI Flow [cite: 45]
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What do you want to learn today?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.neonGreen),
                  filled: true,
                  fillColor: AppTheme.surfaceGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.neonGreen, width: 1),
                  ),
                ),
                onSubmitted: (value) {
                  // Direct question asking -> Go to session
                  context.push('/session');
                },
              ),
            ),

            const SizedBox(height: 30),

            // 4. SUBJECTS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // "See All" allows expansion later
                TextButton(
                  onPressed: () {},
                  child: const Text("See All", style: TextStyle(color: AppTheme.textGrey)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal List of Subjects
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _subjects.length,
                separatorBuilder: (c, i) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  return _SubjectTile(
                    title: subject['name'],
                    progress: subject['progress'],
                    color: subject['color'],
                    icon: subject['icon'],
                    onTap: () => context.push('/session'), // Navigate to session
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // 5. RECENT ACTIVITY SECTION
            const Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Hardcoded recent items for demo
            const _ActivityItem(
              title: 'Newton\'s Second Law',
              subtitle: 'Physics • 2 mins ago',
              icon: Icons.bolt,
              color: Colors.blueAccent,
            ),
            const _ActivityItem(
              title: 'Calculus: Derivatives',
              subtitle: 'Math • 5 hours ago',
              icon: Icons.calculate,
              color: Colors.tealAccent,
            ),
            const _ActivityItem(
              title: 'Periodic Table',
              subtitle: 'Chemistry • 1 day ago',
              icon: Icons.science,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _SubjectTile extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          // Gradient hover effect could go here
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            // Text & Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  color: color,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white
          ),
        ),
        subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
        onTap: () {
          // Resume session logic
        },
      ),
    );
  }
}