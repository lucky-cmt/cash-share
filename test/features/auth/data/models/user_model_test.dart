import 'package:cash_distro/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('UserModel', () {
    test('fromSupabaseUser maps metadata full_name and avatar_url', () {
      const supaUser = supabase.User(
        id: 'u-123',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Chera Mihiretu',
          'avatar_url': 'https://example.com/avatar.png',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
        email: 'chera@example.com',
      );

      final model = UserModel.fromSupabaseUser(supaUser);

      expect(model.id, 'u-123');
      expect(model.email, 'chera@example.com');
      expect(model.displayName, 'Chera Mihiretu');
      expect(model.avatarUrl, 'https://example.com/avatar.png');
    });

    test('fromJson handles nested user_metadata', () {
      final model = UserModel.fromJson({
        'id': 'u-456',
        'email': 'friend@example.com',
        'user_metadata': {
          'name': 'Friend',
          'picture': 'https://example.com/pic.png',
        },
      });

      expect(model.id, 'u-456');
      expect(model.email, 'friend@example.com');
      expect(model.displayName, 'Friend');
      expect(model.avatarUrl, 'https://example.com/pic.png');
    });
  });
}
