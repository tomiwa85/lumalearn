import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the current user from the Auth Service
    final user = ref.watch(authServiceProvider).currentUser;
    final email = user?.email ?? 'Guest User';

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings logic can go here later
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 2. AVATAR SECTION
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceGrey,
                  border: Border.all(color: AppTheme.neonGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // 3. USER INFO
            Text(
              email,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Student Account",
              style: TextStyle(color: AppTheme.textGrey),
            ),

            const SizedBox(height: 40),

            // 4. MENU ITEMS (Placeholders for now)
            _ProfileMenuItem(
                icon: Icons.history,
                text: "Learning History",
                onTap: () {}
            ),
            _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                text: "Notifications",
                onTap: () {}
            ),
            _ProfileMenuItem(
                icon: Icons.lock_outline,
                text: "Privacy & Security",
                onTap: () {}
            ),

            const SizedBox(height: 40),

            // 5. SIGN OUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1), // Subtle red background
                  foregroundColor: Colors.redAccent, // Red text/icon
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: () async {
                  // Call Sign Out
                  await ref.read(authServiceProvider).signOut();
                  // The Router Guard we wrote earlier will automatically
                  // detect the logout and push you to the Login Screen.
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text("Sign Out"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for List Items
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.neonGreen),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}