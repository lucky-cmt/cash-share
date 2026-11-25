import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers device push tokens with Supabase for group expense alerts.
class PushTokenService {
  final SupabaseClient _supabase;

  PushTokenService(this._supabase);

  Future<void> registerToken(String token) async {
    // TODO: Upsert device push token for the authenticated user in Supabase.
    _supabase.auth.currentUser;
  }
}
