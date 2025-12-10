import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Get current user (if any)
  User? get currentUser => _supabase.auth.currentUser;

  // Sign Up with Email
  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign In with Email
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

// THE PROVIDER
// This lets any screen in your app access these auth functions
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

// WATCH USER STATE
// This provider updates automatically whenever the user logs in or out
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});